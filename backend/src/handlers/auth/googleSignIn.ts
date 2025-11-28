import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import {
  AdminCreateUserCommand,
  AdminInitiateAuthCommand,
  AdminSetUserPasswordCommand,
  AuthFlowType,
  CognitoIdentityProviderClient,
} from '@aws-sdk/client-cognito-identity-provider';
import { OAuth2Client } from 'google-auth-library';
import { createHmac } from 'node:crypto';
import { z } from 'zod';

import { successResponse, errorResponse } from '../../utils/response.js';

const region = process.env.AWS_REGION ?? 'us-east-1';
const userPoolId = process.env.COGNITO_USER_POOL_ID!;
const clientId = process.env.COGNITO_CLIENT_ID!;
const googleClientId = process.env.GOOGLE_CLIENT_ID!;
const googleAuthSecret = process.env.GOOGLE_AUTH_SECRET!;

const cognito = new CognitoIdentityProviderClient({ region });
const oauthClient = new OAuth2Client(googleClientId);

const requestSchema = z.object({
  idToken: z.string().min(10, 'Google ID token is required'),
});

function derivePassword(googleSub: string): string {
  return createHmac('sha256', googleAuthSecret).update(googleSub).digest('hex');
}

async function ensureUser(
  email: string,
  googleSub: string,
  name?: string,
  emailVerified?: boolean,
) {
  const password = derivePassword(googleSub);

  try {
    await cognito.send(
      new AdminCreateUserCommand({
        UserPoolId: userPoolId,
        Username: email,
        UserAttributes: [
          { Name: 'email', Value: email },
          { Name: 'email_verified', Value: emailVerified ? 'true' : 'false' },
          ...(name ? [{ Name: 'name', Value: name }] : []),
        ],
        TemporaryPassword: password,
        MessageAction: 'SUPPRESS',
        DesiredDeliveryMediums: [],
      }),
    );
  } catch (error: any) {
    if (error.name !== 'UsernameExistsException') {
      throw error;
    }
  }

  await cognito.send(
    new AdminSetUserPasswordCommand({
      UserPoolId: userPoolId,
      Username: email,
      Password: password,
      Permanent: true,
    }),
  );

  return password;
}

async function loginWithDerivedPassword(email: string, password: string) {
  const response = await cognito.send(
    new AdminInitiateAuthCommand({
      UserPoolId: userPoolId,
      ClientId: clientId,
      AuthFlow: AuthFlowType.ADMIN_USER_PASSWORD_AUTH,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    }),
  );

  if (!response.AuthenticationResult) {
    throw new Error('Failed to authenticate with Cognito');
  }

  return {
    accessToken: response.AuthenticationResult.AccessToken ?? '',
    refreshToken: response.AuthenticationResult.RefreshToken ?? '',
    idToken: response.AuthenticationResult.IdToken ?? '',
    expiresIn: response.AuthenticationResult.ExpiresIn ?? 3600,
  };
}

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const body = requestSchema.parse(JSON.parse(event.body ?? '{}'));

    const ticket = await oauthClient.verifyIdToken({
      idToken: body.idToken,
      audience: googleClientId,
    });

    const payload = ticket.getPayload();
    if (!payload?.sub || !payload.email) {
      throw new Error('Invalid Google token payload');
    }

    const derivedPassword = await ensureUser(
      payload.email,
      payload.sub,
      payload.name ?? undefined,
      payload.email_verified,
    );

    const tokens = await loginWithDerivedPassword(payload.email, derivedPassword);

    return successResponse(
      {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        idToken: tokens.idToken,
        expiresIn: tokens.expiresIn,
      },
      200,
      'Google sign-in succeeded',
    );
  } catch (error: any) {
    if (error.name === 'ZodError') {
      return errorResponse(
        'Validation error',
        400,
        error.errors.map((e: any) => e.message).join(', '),
      );
    }
    return errorResponse(error.message || 'Failed to complete Google sign-in', 400);
  }
};


