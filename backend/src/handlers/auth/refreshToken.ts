import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { refreshTokens } from '../../utils/cognito.js';
import { refreshTokenSchema } from '../../utils/validation.js';
import { successResponse, errorResponse } from '../../utils/response.js';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const body = JSON.parse(event.body ?? '{}');
    const validated = refreshTokenSchema.parse(body);

    const tokens = await refreshTokens(validated.refreshToken);

    return successResponse(
      {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        idToken: tokens.idToken,
        expiresIn: tokens.expiresIn,
      },
      200,
      'Tokens refreshed successfully',
    );
  } catch (error: any) {
    if (error.name === 'ZodError') {
      return errorResponse(
        'Validation error',
        400,
        error.errors.map((e: any) => e.message).join(', '),
      );
    }
    return errorResponse(error.message || 'Failed to refresh tokens', 401);
  }
};


