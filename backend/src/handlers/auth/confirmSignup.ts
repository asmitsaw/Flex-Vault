import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { confirmSignUp } from '../../utils/cognito.js';
import { confirmSignupSchema } from '../../utils/validation.js';
import { successResponse, errorResponse } from '../../utils/response.js';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const body = JSON.parse(event.body ?? '{}');
    const validated = confirmSignupSchema.parse(body);

    await confirmSignUp(validated.email, validated.code);

    return successResponse(
      { email: validated.email },
      200,
      'Email verified successfully',
    );
  } catch (error: any) {
    if (error.name === 'ZodError') {
      return errorResponse(
        'Validation error',
        400,
        error.errors.map((e: any) => e.message).join(', '),
      );
    }
    return errorResponse(error.message || 'Failed to confirm signup', 400);
  }
};


