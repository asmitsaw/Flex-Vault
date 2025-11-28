# Data Flow Documentation

## Upload Sequence

```mermaid
sequenceDiagram
  autonumber
  participant Client
  participant API as API Gateway
  participant UploadLambda as presignUpload Lambda
  participant S3
  participant CallbackLambda as metadataCallback Lambda
  participant SQS as Jobs Queue
  participant Worker as batchInference Lambda
  participant DDB as DynamoDB

  Client->>API: POST /upload/presign (JWT)
  API->>UploadLambda: Invoke
  UploadLambda->>DDB: Put Upload record
  UploadLambda->>Client: { uploadUrl, key }
  Client->>S3: PUT object via presigned URL
  S3-->>CallbackLambda: ObjectCreated event
  CallbackLambda->>DDB: Update file status=READY
  CallbackLambda->>SQS: Send job {key,userId}
  Worker->>SQS: Consume
  Worker->>S3: Get object (planned)
  Worker->>DDB: Update tags, embeddingId
```

## Authentication Sequence

```mermaid
sequenceDiagram
  autonumber
  participant Client
  participant API as API Gateway
  participant AuthLambda as auth/login Lambda
  participant Cognito

  Client->>API: POST /auth/login
  API->>AuthLambda: Invoke
  AuthLambda->>Cognito: InitiateAuth USER_PASSWORD_AUTH
  Cognito-->>AuthLambda: Tokens
  AuthLambda-->>Client: accessToken, refreshToken, idToken
```

## File State Diagram

```mermaid
stateDiagram-v2
  [*] --> PENDING
  PENDING --> READY: S3 callback
  READY --> ENRICHED: Batch inference updates tags/embedding
  READY --> DELETING: User action
  ENRICHED --> [*]
  DELETING --> [*]
```

## Event Logging

- Lambda logs: CloudWatch (see deployment guide `backend/infra/DEPLOYMENT.md:134`).
- Client logs: `lib/core/utils/app_logger.dart:3` via `logger` package.

