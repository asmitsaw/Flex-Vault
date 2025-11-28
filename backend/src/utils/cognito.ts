import {
  CognitoIdentityProviderClient,
  SignUpCommand,
  AdminInitiateAuthCommand,
  InitiateAuthCommand,
  ConfirmSignUpCommand,
  ForgotPasswordCommand,
  ConfirmForgotPasswordCommand,
  AdminGetUserCommand,
  GetUserCommand,
  AuthFlowType,
} from '@aws-sdk/client-cognito-identity-provider';
import type { APIGatewayProxyEventV2 } from 'aws-lambda';

const region = process.env.AWS_REGION ?? 'us-east-1';
const userPoolId = process.env.COGNITO_USER_POOL_ID!;
const clientId = process.env.COGNITO_CLIENT_ID!;

export const cognitoClient = new CognitoIdentityProviderClient({ region });

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  idToken: string;
  expiresIn: number;
}

export interface CognitoUser {
  sub: string;
  email: string;
  emailVerified: boolean;
  name?: string;
}

export async function signUp(
  email: string,
  password: string,
  name: string,
): Promise<{ userId: string }> {
  try {
    const command = new SignUpCommand({
      ClientId: clientId,
      Username: email,
      Password: password,
      UserAttributes: [
        { Name: 'email', Value: email },
        { Name: 'name', Value: name },
      ],
    });

    const response = await cognitoClient.send(command);
    return { userId: response.UserSub ?? '' };
  } catch (error: any) {
    if (error.name === 'UsernameExistsException') {
      throw new Error('User already exists');
    }
    if (error.name === 'InvalidPasswordException') {
      throw new Error('Password does not meet requirements');
    }
    throw new Error(error.message || 'Failed to sign up');
  }
}

export async function confirmSignUp(
  email: string,
  code: string,
): Promise<void> {
  try {
    const command = new ConfirmSignUpCommand({
      ClientId: clientId,
      Username: email,
      ConfirmationCode: code,
    });

    await cognitoClient.send(command);
  } catch (error: any) {
    if (error.name === 'CodeMismatchException') {
      throw new Error('Invalid verification code');
    }
    if (error.name === 'ExpiredCodeException') {
      throw new Error('Verification code has expired');
    }
    throw new Error(error.message || 'Failed to confirm sign up');
  }
}

export async function login(
  email: string,
  password: string,
): Promise<AuthTokens> {
  try {
    const command = new InitiateAuthCommand({
      ClientId: clientId,
      AuthFlow: AuthFlowType.USER_PASSWORD_AUTH,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    });

    const response = await cognitoClient.send(command);

    if (!response.AuthenticationResult) {
      throw new Error('Authentication failed');
    }

    return {
      accessToken: response.AuthenticationResult.AccessToken ?? '',
      refreshToken: response.AuthenticationResult.RefreshToken ?? '',
      idToken: response.AuthenticationResult.IdToken ?? '',
      expiresIn: response.AuthenticationResult.ExpiresIn ?? 3600,
    };
  } catch (error: any) {
    if (error.name === 'NotAuthorizedException') {
      throw new Error('Invalid email or password');
    }
    if (error.name === 'UserNotConfirmedException') {
      throw new Error('Please verify your email address');
    }
    throw new Error(error.message || 'Failed to login');
  }
}

export async function refreshTokens(
  refreshToken: string,
): Promise<AuthTokens> {
  try {
    const command = new InitiateAuthCommand({
      ClientId: clientId,
      AuthFlow: AuthFlowType.REFRESH_TOKEN_AUTH,
      AuthParameters: {
        REFRESH_TOKEN: refreshToken,
      },
    });

    const response = await cognitoClient.send(command);

    if (!response.AuthenticationResult) {
      throw new Error('Token refresh failed');
    }

    return {
      accessToken: response.AuthenticationResult.AccessToken ?? '',
      refreshToken: refreshToken, // Refresh token stays the same
      idToken: response.AuthenticationResult.IdToken ?? '',
      expiresIn: response.AuthenticationResult.ExpiresIn ?? 3600,
    };
  } catch (error: any) {
    if (error.name === 'NotAuthorizedException') {
      throw new Error('Invalid refresh token');
    }
    throw new Error(error.message || 'Failed to refresh tokens');
  }
}

export async function forgotPassword(email: string): Promise<void> {
  try {
    const command = new ForgotPasswordCommand({
      ClientId: clientId,
      Username: email,
    });

    await cognitoClient.send(command);
  } catch (error: any) {
    if (error.name === 'UserNotFoundException') {
      // Don't reveal if user exists
      return;
    }
    throw new Error(error.message || 'Failed to initiate password reset');
  }
}

export async function resetPassword(
  email: string,
  code: string,
  newPassword: string,
): Promise<void> {
  try {
    const command = new ConfirmForgotPasswordCommand({
      ClientId: clientId,
      Username: email,
      ConfirmationCode: code,
      Password: newPassword,
    });

    await cognitoClient.send(command);
  } catch (error: any) {
    if (error.name === 'CodeMismatchException') {
      throw new Error('Invalid verification code');
    }
    if (error.name === 'ExpiredCodeException') {
      throw new Error('Verification code has expired');
    }
    throw new Error(error.message || 'Failed to reset password');
  }
}

export async function getUserFromToken(
  accessToken: string,
): Promise<CognitoUser> {
  try {
    const command = new GetUserCommand({
      AccessToken: accessToken,
    });

    const response = await cognitoClient.send(command);

    const attributes = response.UserAttributes ?? [];
    const emailAttr = attributes.find((attr) => attr.Name === 'email');
    const nameAttr = attributes.find((attr) => attr.Name === 'name');
    const emailVerifiedAttr = attributes.find(
      (attr) => attr.Name === 'email_verified',
    );

    return {
      sub: response.Username ?? '',
      email: emailAttr?.Value ?? '',
      emailVerified: emailVerifiedAttr?.Value === 'true',
      name: nameAttr?.Value,
    };
  } catch (error: any) {
    throw new Error('Invalid access token');
  }
}

export function getUserIdFromEvent(
  event: APIGatewayProxyEventV2,
): string | null {
  return event.requestContext.authorizer?.jwt?.claims?.sub ?? null;
}


