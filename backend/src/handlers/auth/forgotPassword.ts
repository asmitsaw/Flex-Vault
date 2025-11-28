import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { forgotPassword } from '../../utils/cognito.js';
import { forgotPasswordSchema } from '../../utils/validation.js';
import { successResponse, errorResponse } from '../../utils/response.js';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const body = JSON.parse(event.body ?? '{}');
    const validated = forgotPasswordSchema.parse(body);

    await forgotPassword(validated.email);

    // Always return success to prevent email enumeration
    return successResponse(
      { email: validated.email },
      200,
      'If an account exists, a password reset code has been sent to your email.',
    );
  } catch (error: any) {
    if (error.name === 'ZodError') {
      return errorResponse(
        'Validation error',
        400,
        error.errors.map((e: any) => e.message).join(', '),
      );
    }
    // Still return success to prevent email enumeration
    return successResponse(
      {},
      200,
      'If an account exists, a password reset code has been sent to your email.',
    );
  }
};


