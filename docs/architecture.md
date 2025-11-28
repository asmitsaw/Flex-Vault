# Architecture Overview

## Serverless Components

- Amazon Cognito User Pools for authentication and user management.
  - Defined in `backend/infra/cdk-stack.ts` and `sam-template.yaml`.
  - Client flows implemented via utility functions in `backend/src/utils/cognito.ts`.

- Amazon API Gateway for REST endpoints.
  - Routes and authorizer configured in `backend/infra/cdk-stack.ts` and `backend/infra/sam-template.yaml`.
  - Public auth endpoints, protected `/me`, `/upload/presign`, `/download/presign`.

- AWS Lambda for business logic.
  - Auth handlers: `backend/src/handlers/auth/*.ts`.
  - File ops: `backend/src/handlers/presignUpload.ts` (`presign upload`) and `backend/src/handlers/presignDownload.ts` (`presign download`).
  - Metadata callback (S3 event): `backend/src/handlers/metadataCallback.ts`.
  - Batch inference worker (SQS): `backend/src/workers/batchInference.ts`.

- Amazon S3 for object storage.
  - Bucket defined in `backend/infra/cdk-stack.ts` and `sam-template.yaml`.
  - S3 `OBJECT_CREATED` triggers `metadataCallback` via `s3n.LambdaDestination` in `backend/infra/cdk-stack.ts`.

- Amazon DynamoDB for metadata and tracking tables.
  - Files table with GSIs (GSI1/GSI2/GSI3) created at `backend/infra/cdk-stack.ts:64` and detailed in `backend/infra/dynamodb-schema.md`.
  - Folders, Uploads, Jobs tables similarly defined.

- Amazon SQS for asynchronous jobs.
  - Queue `flexvault-jobs` defined and consumed by `batchInference` in `backend/infra/cdk-stack.ts`.

- AWS IAM for permissions.
  - Lambda execution role and grants configured in `backend/infra/cdk-stack.ts`.

## AWS Services and Roles

- Cognito: user registration, login, refresh, password reset (`backend/src/utils/cognito.ts:1`).
- API Gateway: routing and CORS (`backend/infra/cdk-stack.ts:180`).
- Lambda: Node.js 20.x functions for handlers and workers (`backend/infra/cdk-stack.ts:108`).
- S3: versioned bucket for files (`backend/infra/sam-template.yaml:38`).
- DynamoDB: `flexvault-files`, `flexvault-folders`, `flexvault-uploads`, `flexvault-jobs` with GSIs (`backend/infra/cdk-stack.ts:64`).
- SQS: `flexvault-jobs` queue with 5-min visibility timeout (`backend/infra/cdk-stack.ts:96`).
- IAM: `AWSLambdaBasicExecutionRole` plus table, bucket, and queue grants (`backend/infra/cdk-stack.ts:114`).

## ML Integration Architecture

- Data Sources
  - Client-side metadata: Google ML Kit labels and OCR extracted in `lib/core/services/upload_service.dart:89`.
  - Server-side enrichment: S3 upload triggers `metadataCallback` (`backend/src/handlers/metadataCallback.ts:1`) which enqueues jobs to SQS.

- Inference Pipeline
  - Trigger: S3 `OBJECT_CREATED` → Lambda `metadataCallback` updates DynamoDB and sends SQS job (`backend/src/handlers/metadataCallback.ts:24`).
  - Worker: `batchInference` consumes SQS records and appends tags + `embeddingId` placeholder (`backend/src/workers/batchInference.ts:17`).
  - Status: File item status transitions via DynamoDB update (`READY`) in callback.

- Algorithms Implemented
  - Client-side: image labeling and text recognition via ML Kit.
  - Server-side: placeholder for embeddings/OCR; to be implemented with AWS services like Amazon Comprehend, Textract, or SageMaker.

## Security Implementation

- Encryption
  - S3 bucket versioning enabled; encryption configuration not explicitly set in templates. Recommend enabling SSE-S3 or SSE-KMS.
  - In-transit encryption via HTTPS for API Gateway and presigned URLs.

- IAM Policies
  - Lambda role with `AWSLambdaBasicExecutionRole`; explicit grants to S3, DynamoDB tables, SQS queue, and Cognito actions (`backend/infra/cdk-stack.ts:114`).
  - Principle of least privilege to be refined for specific operations.

- Authentication / Authorization
  - Cognito authorizer attached to protected endpoints (`backend/infra/cdk-stack.ts:206`).
  - JWT parsing and identity extraction (`backend/src/utils/cognito.ts:219`).

## File Organization Logic Flow

1. Client selects file and extracts metadata (`lib/core/services/upload_service.dart:21`, `:89`).
2. Client requests presigned upload URL (`/upload/presign`) (`backend/src/handlers/presignUpload.ts:1`).
3. Uploads to S3 using presigned URL; S3 triggers `metadataCallback` (`backend/src/handlers/metadataCallback.ts:1`).
4. Callback updates file status and size; enqueues ML job to SQS (`backend/src/handlers/metadataCallback.ts:24`).
5. Batch inference appends tags and embeddingId (`backend/src/workers/batchInference.ts:17`).
6. Tagging system stored in DynamoDB `tags` list; manual or client-side tags can be merged.

## Search Functionality Architecture

- Current: No server-side search implementation in codebase; `embeddingId` suggests planned vector index.
- Planned Strategy
  - Indexing: Maintain vector embeddings and metadata attributes; suitable backends include OpenSearch with k-NN or DynamoDB + AWS Vector.
  - Query Processing: Combine keyword filters with vector similarity; rerank using metadata and tag matches.
  - Relevance Scoring: Weighted combination of vector similarity, tag overlap, recency, and folder context.

References:
- Files table creation: `backend/infra/cdk-stack.ts:64`
- Presign upload handler: `backend/src/handlers/presignUpload.ts:1`
- Presign download handler: `backend/src/handlers/presignDownload.ts:1`
- Metadata callback: `backend/src/handlers/metadataCallback.ts:1`
- Batch inference worker: `backend/src/workers/batchInference.ts:1`
- Cognito utilities: `backend/src/utils/cognito.ts:1`

