import type { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { errorResponse } from './response.js';
import { getUserIdFromEvent } from './cognito.js';

/**
 * Middleware to ensure user is authenticated
 */
export function requireAuth(
  event: APIGatewayProxyEventV2,
): { userId: string } | APIGatewayProxyResultV2 {
  const userId = getUserIdFromEvent(event);
  if (!userId) {
    return errorResponse('Unauthorized', 401);
  }
  return { userId };
}

/**
 * Parse JSON body with error handling
 */
export function parseBody<T = unknown>(
  body: string | null | undefined,
): T | null {
  if (!body) {
    return null;
  }
  try {
    return JSON.parse(body) as T;
  } catch {
    return null;
  }
}

/**
 * Get query parameter
 */
export function getQueryParam(
  event: APIGatewayProxyEventV2,
  param: string,
): string | undefined {
  return event.queryStringParameters?.[param] || event.queryStringParameters?.[param.toLowerCase()];
}

/**
 * Get header value
 */
export function getHeader(
  event: APIGatewayProxyEventV2,
  header: string,
): string | undefined {
  const lowerHeader = header.toLowerCase();
  return event.headers[header] || event.headers[lowerHeader] || event.headers[header.toUpperCase()];
}


