import { SQSEvent } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, UpdateCommand } from '@aws-sdk/lib-dynamodb';

const region = process.env.AWS_REGION ?? 'us-east-1';
const filesTable = process.env.FLEXVAULT_TABLE!;

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({ region }));

export const handler = async (event: SQSEvent) => {
  for (const record of event.Records) {
    const payload = JSON.parse(record.body);
    const { key, userId } = payload;

    // TODO: fetch file from S3, run embeddings/OCR.
    const tags = ['AI', 'Auto', 'Tag'];
    const embeddingId = `embed-${Date.now()}`;

    await ddb.send(
      new UpdateCommand({
        TableName: filesTable,
        Key: { pk: `${userId}#${key}`, sk: key },
        UpdateExpression:
          'SET tags = list_append(if_not_exists(tags, :emptyList), :tags), embeddingId = :embeddingId',
        ExpressionAttributeValues: {
          ':tags': tags,
          ':embeddingId': embeddingId,
          ':emptyList': [],
        },
      }),
    );
  }
};

