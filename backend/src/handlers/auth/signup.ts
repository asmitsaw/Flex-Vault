import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { signUp } from '../../utils/cognito.js';
import { signupSchema } from '../../utils/validation.js';
import { successResponse, errorResponse } from '../../utils/response.js';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const body = JSON.parse(event.body ?? '{}');
    const validated = signupSchema.parse(body);

    const { userId } = await signUp(
      validated.email,
      validated.password,
      validated.name,
    );

    return successResponse(
      { userId, email: validated.email },
      201,
      'User registered successfully. Please check your email for verification code.',
    );
  } catch (error: any) {
    if (error.name === 'ZodError') {
      return errorResponse(
        'Validation error',
        400,
        error.errors.map((e: any) => e.message).join(', '),
      );
    }
    return errorResponse(error.message || 'Failed to sign up', 400);
  }
};


