import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { login } from '../../utils/cognito.js';
import { loginSchema } from '../../utils/validation.js';
import { successResponse, errorResponse } from '../../utils/response.js';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const body = JSON.parse(event.body ?? '{}');
    const validated = loginSchema.parse(body);

    const tokens = await login(validated.email, validated.password);

    return successResponse(
      {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        idToken: tokens.idToken,
        expiresIn: tokens.expiresIn,
      },
      200,
      'Login successful',
    );
  } catch (error: any) {
    if (error.name === 'ZodError') {
      return errorResponse(
        'Validation error',
        400,
        error.errors.map((e: any) => e.message).join(', '),
      );
    }
    return errorResponse(error.message || 'Failed to login', 401);
  }
};


