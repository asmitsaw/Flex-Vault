import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { GetObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';

const region = process.env.AWS_REGION ?? 'us-east-1';
const bucket = process.env.FLEXVAULT_BUCKET!;
const filesTable = process.env.FLEXVAULT_TABLE!;

const s3 = new S3Client({ region });
const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({ region }));

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const userId = event.requestContext.authorizer?.jwt.claims.sub;
  if (!userId) {
    return { statusCode: 401, body: 'Unauthorized' };
  }

  const key = event.queryStringParameters?.key;
  if (!key) {
    return { statusCode: 400, body: 'Missing key' };
  }

  const file = await ddb.send(
    new GetCommand({
      TableName: filesTable,
      Key: { pk: `${userId}#${key}`, sk: key },
    }),
  );

  if (!file.Item) {
    return { statusCode: 404, body: 'File not found' };
  }

  const command = new GetObjectCommand({
    Bucket: bucket,
    Key: key,
  });

  const downloadUrl = await getSignedUrl(s3, command, { expiresIn: 600 });

  return {
    statusCode: 200,
    body: JSON.stringify({ downloadUrl }),
  };
};

