# FlexVault Backend

This directory contains an AWS-native implementation blueprint for FlexVault. It includes Lambda handlers, infrastructure guidance, and worker examples that mirror the mobile features.

## Components

| Area | Service | Notes |
| --- | --- | --- |
| Auth | Cognito User Pools | Hosted UI, JWT access tokens; federated SSO ready |
| APIs | API Gateway (REST) + Lambda (Node.js) | Routes for presigned uploads/downloads, metadata, folders |
| Storage | S3 + KMS CMK | Private bucket per environment; lifecycle for temp uploads |
| Metadata | DynamoDB | `Files`, `Folders`, `Uploads`, `Jobs` tables with GSIs |
| Async | SQS + Lambda workers | Batch ML inference, duplicate resolution |
| ML heavy | SageMaker endpoint / ECS task | Embeddings, high-accuracy OCR |
| Search (future) | OpenSearch / vector DB | Semantic search, similarity |

## Local Development

1. Install dependencies
   ```bash
   cd backend
   npm install
   ```
2. Set environment variables:
   ```bash
   cp .env.example .env
   # populate FLEXVAULT_BUCKET, FLEXVAULT_TABLE, GOOGLE_CLIENT_ID, GOOGLE_AUTH_SECRET, etc.
   ```
3. Run tests / lint:
   ```bash
   npm run lint
   npm test
   ```

## Deployment Workflow

1. Use AWS CDK / Terraform to provision Cognito, API Gateway, Lambdas, DynamoDB, S3, SQS, CloudWatch, IAM roles.
2. Package Lambdas via `npm run build` and deploy (CDK `cdk deploy`, Terraform `apply`, or SAM `sam deploy`).
3. Configure API Gateway custom domain + WAF.
4. Update mobile `.env` (or build time vars) with API base URL and Cognito client IDs.

## Directory Structure

```
backend/
 ├─ package.json
 ├─ src/
 │   ├─ handlers/
 │   │   ├─ auth/
 │   │   │   ├─ signup.ts
 │   │   │   ├─ login.ts
 │   │   │   ├─ confirmSignup.ts
 │   │   │   ├─ refreshToken.ts
 │   │   │   ├─ forgotPassword.ts
 │   │   │   ├─ resetPassword.ts
 │   │   │   └─ me.ts
 │   │   ├─ presignUpload.ts
 │   │   ├─ presignDownload.ts
 │   │   └─ metadataCallback.ts
 │   ├─ utils/
 │   │   ├─ cognito.ts
 │   │   ├─ validation.ts
 │   │   ├─ response.ts
 │   │   └─ middleware.ts
 │   └─ workers/
 │       └─ batchInference.ts
 └─ infra/
     ├─ cdk-stack.ts
     ├─ cdk-app.ts
     ├─ sam-template.yaml
     ├─ DEPLOYMENT.md
     └─ dynamodb-schema.md
```

## DynamoDB Schema Snapshot

```
Files (PK: userId#fileId, SK: fileId)
  GSIs:
    - GSI1: folderId, createdAt
    - GSI2: userId, status
    - GSI3: userId, tag

Folders (PK: userId#folderId)
Uploads (PK: uploadId) // TTL 24h
Jobs (PK: jobId)       // for async ML tasks
```

## Security Considerations

- Cognito authorizer checks for every API Lambda.
- Presigned URLs scoped to `userId` prefix and short expiration.
- KMS-encrypted environment variables for secrets.
- CloudWatch alarms on auth failures and anomalous upload volume.
- Optional client-side encryption key exchange via Cognito signed attributes.

## API Endpoints

### Authentication Endpoints

- `POST /auth/signup` - Register a new user
- `POST /auth/login` - Authenticate and get tokens
- `POST /auth/google` - Sign in with Google OAuth
- `POST /auth/confirm-signup` - Confirm email with verification code
- `POST /auth/refresh-token` - Refresh access token
- `POST /auth/forgot-password` - Request password reset code
- `POST /auth/reset-password` - Reset password with code
- `GET /me` - Get current user info (protected)

### File Management Endpoints

- `POST /upload/presign` - Get presigned upload URL (protected)
- `GET /download/presign?key=<file-key>` - Get presigned download URL (protected)

## Authentication Flow

1. User signs up via `/auth/signup`
2. User receives verification code via email
3. User confirms email via `/auth/confirm-signup`
4. User logs in via `/auth/login` to get access/refresh tokens
5. User includes `Authorization: Bearer <access-token>` header for protected endpoints
6. When access token expires, use `/auth/refresh-token` with refresh token

## Next Steps

- Deploy infrastructure using CDK or SAM (see `infra/DEPLOYMENT.md`)
- Connect DynamoDB Streams → SQS to trigger re-tagging when metadata changes
- Add OpenSearch ingestion pipeline when semantic search is prioritized
- Integrate with Flutter mobile app (update `ApiClient` to include JWT tokens)

