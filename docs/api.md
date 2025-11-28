# API Documentation

## Base URL

- Configured via environment `FLEXVAULT_API_URL` on the client (`lib/core/services/api_client.dart:12`).
- CDK outputs API URL after deployment (`backend/infra/cdk-stack.ts:248`).

## Endpoints

### Public

- `POST /auth/signup`
  - Body: `{ email, password, name }`
  - Response: `{ success, data: { userId, email }, message }`
  - Handler: `backend/src/handlers/auth/signup.ts:1`

- `POST /auth/login`
  - Body: `{ email, password }`
  - Response: `{ success, data: { accessToken, refreshToken, idToken, expiresIn }, message }`
  - Handler: `backend/src/handlers/auth/login.ts:1`

- `POST /auth/confirm-signup`
  - Body: `{ email, code }`
  - Handler: `backend/src/handlers/auth/confirmSignup.ts:1`

- `POST /auth/forgot-password`
  - Body: `{ email }`
  - Handler: `backend/src/handlers/auth/forgotPassword.ts:1`

- `POST /auth/reset-password`
  - Body: `{ email, code, newPassword }`
  - Handler: `backend/src/handlers/auth/resetPassword.ts:1`

### Protected

- `GET /me`
  - Header: `Authorization: Bearer <accessToken>`
  - Response: `{ success, data: { userId, email, emailVerified, name } }`
  - Handler: `backend/src/handlers/auth/me.ts:1`

- `POST /upload/presign`
  - Header: `Authorization: Bearer <accessToken>`
  - Body: `{ filename, contentType, size, hash }`
  - Response: `{ uploadUrl, key }`
  - Handler: `backend/src/handlers/presignUpload.ts:1`

- `GET /download/presign?key=<file-key>`
  - Header: `Authorization: Bearer <accessToken>`
  - Response: `{ downloadUrl }`
  - Handler: `backend/src/handlers/presignDownload.ts:1`

## Error Handling

- Standard response wrapper in `backend/src/utils/response.ts:1` with CORS headers.
- Validation via `zod` schemas (`backend/src/utils/validation.ts:1`).

## OpenAPI

- See `docs/openapi.yaml` for machine-readable specification.

