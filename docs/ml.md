# ML Processes

## Current Implementation

- Client-side metadata extraction using Google ML Kit
  - Image labeling: `lib/core/services/upload_service.dart:89`
  - Text recognition (OCR): `lib/core/services/upload_service.dart:89`
  - Perceptual hash placeholder: file length to string; to replace with real pHash.

- Server-side enrichment
  - S3 event → `metadataCallback` updates DynamoDB and enqueues job (`backend/src/handlers/metadataCallback.ts:24`).
  - `batchInference` consumes SQS and appends `tags` and `embeddingId` (`backend/src/workers/batchInference.ts:17`).

## Planned Training Pipeline

- Data Lake: S3 bucket prefix `training/` for labeled datasets.
- Feature Engineering: text extraction (Textract), image embeddings (SageMaker or Amazon Rekognition).
- Model Training: SageMaker jobs producing vector indexes and classification models.
- Registry: Model artifacts and metadata stored in S3 with versioning.

## Inference Services

- Batch Inference: SQS-triggered Lambda processes new uploads, generates embeddings, updates DynamoDB.
- Real-time Inference: optional Lambda for on-demand classification; not present in current codebase.

## SLA Targets (proposed)

- Batch completion within 5 minutes for 95th percentile.
- Error rate < 1% with automatic retries via SQS redrive.

