import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { resetPassword } from '../../utils/cognito.js';
import { resetPasswordSchema } from '../../utils/validation.js';
import { successResponse, errorResponse } from '../../utils/response.js';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const body = JSON.parse(event.body ?? '{}');
    const validated = resetPasswordSchema.parse(body);

    await resetPassword(validated.email, validated.code, validated.newPassword);

    return successResponse(
      { email: validated.email },
      200,
      'Password reset successfully',
    );
  } catch (error: any) {
    if (error.name === 'ZodError') {
      return errorResponse(
        'Validation error',
        400,
        error.errors.map((e: any) => e.message).join(', '),
      );
    }
    return errorResponse(error.message || 'Failed to reset password', 400);
  }
};


