import { APIGatewayProxyHandlerV2 } from 'aws-lambda';
import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'node:crypto';

const region = process.env.AWS_REGION ?? 'us-east-1';
const bucket = process.env.FLEXVAULT_BUCKET!;
const uploadsTable = process.env.FLEXVAULT_UPLOAD_TABLE!;
const expiry = Number(process.env.FLEXVAULT_PRESIGN_EXPIRY ?? 900);

const s3 = new S3Client({ region });
const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({ region }));

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const userId = event.requestContext.authorizer?.jwt.claims.sub;
  if (!userId) {
    return { statusCode: 401, body: 'Unauthorized' };
  }

  const body = JSON.parse(event.body ?? '{}');
  const { filename, contentType, size, hash } = body;

  const key = `${userId}/${Date.now()}-${filename}`;
  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    ContentType: contentType,
    Metadata: {
      'x-flexvault-user': userId,
      'x-flexvault-hash': hash ?? '',
    },
  });

  const uploadUrl = await getSignedUrl(s3, command, { expiresIn: expiry });

  await ddb.send(
    new PutCommand({
      TableName: uploadsTable,
      Item: {
        uploadId: randomUUID(),
        userId,
        key,
        filename,
        size,
        status: 'PENDING',
        createdAt: new Date().toISOString(),
        ttl: Math.floor(Date.now() / 1000) + 3600,
      },
    }),
  );

  return {
    statusCode: 200,
    body: JSON.stringify({ uploadUrl, key }),
  };
};

