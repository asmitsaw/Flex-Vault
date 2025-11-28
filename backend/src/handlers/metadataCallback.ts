import { S3Event, Context } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const region = process.env.AWS_REGION ?? 'us-east-1';
const filesTable = process.env.FLEXVAULT_TABLE!;
const jobsQueueUrl = process.env.FLEXVAULT_JOBS_QUEUE!;

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({ region }));
const sqs = new SQSClient({ region });

export const handler = async (event: S3Event, _context: Context) => {
  for (const record of event.Records) {
    const key = decodeURIComponent(record.s3.object.key);
    const userId = key.split('/')[0];

    await ddb.send(
      new UpdateCommand({
        TableName: filesTable,
        Key: { pk: `${userId}#${key}`, sk: key },
        UpdateExpression:
          'SET #status = :ready, updatedAt = :updatedAt, size = :size',
        ExpressionAttributeNames: {
          '#status': 'status',
        },
        ExpressionAttributeValues: {
          ':ready': 'READY',
          ':updatedAt': new Date().toISOString(),
          ':size': record.s3.object.size,
        },
      }),
    );

    await sqs.send(
      new SendMessageCommand({
        QueueUrl: jobsQueueUrl,
        MessageBody: JSON.stringify({
          jobType: 'EMBEDDING',
          key,
          userId,
        }),
      }),
    );
  }
};

