# FlexVault Mobile + Backend

FlexVault is a warm, minimal AI-first cloud storage experience. This repo contains:

- Flutter mobile client (lib/)
- AWS backend blueprints (`backend/`)
- Design tokens, routes, and service scaffolding for presigned uploads, on-device ML, and DynamoDB metadata.

## Prerequisites

- Flutter 3.24+
- Dart 3.5+
- Xcode / Android Studio command-line tools
- AWS CLI (for backend)

## Running the App

```bash
flutter pub get
flutter run
```

Key entry points:

- `lib/main.dart` – initializes Hive + Riverpod.
- `lib/app.dart` – MaterialApp with router + light/dark theme.
- `lib/core/routes/app_router.dart` – route table (splash, onboarding, auth, shell, preview, upload manager).

## Architecture Overview

| Layer | Details |
| --- | --- |
| UI | Feature-first folders under `lib/features/*`. Each screen matches the FlexVault spec (Splash, Onboarding, Auth, Home, Gallery, Preview, Smart Folders, Upload Manager, Settings). |
| State | `flutter_riverpod` for dependency injection and future state management. |
| Theme | `FlexVaultTheme` defines warm pastel colors + dark mode, using Google Fonts (Poppins, Inter, Roboto). |
| Services | `ApiClient` (Dio) + `UploadService` (file picker, compression, ML Kit metadata, presign handshake). |
| Models | `FileEntry` (equatable, JSON helpers) ready for DynamoDB metadata. |

## Backend

- `backend/README.md` explains AWS components.
- Node.js Lambdas for presigned upload/download, metadata confirmation, and SQS batch inference.
- DynamoDB schema doc under `backend/infra/dynamodb-schema.md`.

Deploy backend via CDK/Terraform, update mobile `--dart-define` values:

```
flutter run --dart-define=FLEXVAULT_API_URL=https://api.flexvault.app
```

## Next Steps

- Wire Cognito tokens into `ApiClient` headers.
- Replace mock data in UI with repository implementations once backend is live.
- Extend `UploadService` for duplicate detection + destination folders.
- Add tests (unit + golden) for components and Lambdas.
