# DynamoDB Tables

## Files

| Attribute | Type | Notes |
| --- | --- | --- |
| pk | string | `userId#fileId` |
| sk | string | `fileId` |
| folderId | string | Parent folder |
| tags | list<string> | AI + user tags |
| status | string | `PENDING`, `READY`, `DELETING` |
| ocrText | string | truncated text blob |
| hash | string | perceptual hash for duplicates |
| embeddingId | string | reference for vector index |

### Indexes

- GSI1: `folderId` (PK) + `createdAt` (SK)
- GSI2: `userId` (PK) + `status` (SK)
- GSI3: `userId` (PK) + `tag` (SK, using `tags` as sparse attribute)

## Folders

`pk = userId#folderId` / `sk = folderId`
- `rules`: JSON definition of smart folder criteria.
- `color`, `icon`, `stats`.

## Uploads

Temporary tracking table for in-flight uploads. TTL attribute ensures cleanup.

## Jobs

Tracks inference / OCR jobs triggered through SQS. Contains attempt counters, lastError, status transitions.

