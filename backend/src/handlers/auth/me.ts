import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { getUserFromToken, getUserIdFromEvent } from '../../utils/cognito.js';
import { successResponse, errorResponse } from '../../utils/response.js';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const userId = getUserIdFromEvent(event);
    if (!userId) {
      return errorResponse('Unauthorized', 401);
    }

    // Get access token from Authorization header
    const authHeader = event.headers.authorization || event.headers.Authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse('Missing or invalid authorization header', 401);
    }

    const accessToken = authHeader.substring(7);
    const user = await getUserFromToken(accessToken);

    return successResponse(
      {
        userId: user.sub,
        email: user.email,
        emailVerified: user.emailVerified,
        name: user.name,
      },
      200,
    );
  } catch (error: any) {
    return errorResponse(error.message || 'Failed to get user info', 401);
  }
};


