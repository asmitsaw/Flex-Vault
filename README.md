# Flex-Vault

![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue? logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3. 5+-0175C2?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)

**A warm, minimal AI-first cloud storage experience** — Flex-Vault combines a cross-platform Flutter mobile client with a production-ready AWS backend for intelligent file management. 

## Table of Contents

- [What is Flex-Vault?](#what-is-flex-vault)
- [Key Features](#key-features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the Mobile App](#running-the-mobile-app)
- [Project Structure](#project-structure)
- [Architecture Overview](#architecture-overview)
  - [Mobile (Flutter)](#mobile-flutter)
  - [Backend (AWS)](#backend-aws)
- [Development](#development)
  - [Mobile Development](#mobile-development)
  - [Backend Development](#backend-development)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Support](#support)

## What is Flex-Vault?

Flex-Vault is a full-stack cloud storage application that brings intelligence to file management. It features:

- **Cross-platform mobile app** built with Flutter (iOS, Android, Web, Windows, macOS, Linux)
- **AWS-native backend** with serverless architecture (Lambda, S3, DynamoDB, Cognito)
- **On-device ML** for image labeling and text recognition
- **Smart features** including AI-powered organization, metadata extraction, and semantic search capabilities

## Key Features

- 🔐 **Secure Authentication** — AWS Cognito with OAuth integration (Google sign-in ready)
- 📁 **Intelligent File Organization** — Smart folders with ML-powered categorization
- 🖼️ **Gallery Preview** — Rich media viewing with on-device image compression
- 🏷️ **Automatic Tagging** — Google ML Kit integration for image labels and OCR
- ☁️ **Cloud Sync** — Presigned S3 uploads with KMS encryption
- 📤 **Batch Processing** — SQS-driven async workers for heavy ML tasks
- 🌈 **Beautiful UI** — Warm pastel design with dark mode support
- ⚡ **State Management** — Riverpod for reactive, dependency-injected state

## Getting Started

### Prerequisites

Ensure you have the following installed:

- **Flutter** 3.24 or higher
- **Dart** 3.5 or higher
- **Xcode** (for iOS development) or **Android Studio** (for Android development)
- **Git**
- **AWS CLI** (optional, for backend deployment)

Verify your setup:

```bash
flutter --version
dart --version
```

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/asmitsaw/Flex-Vault.git
cd Flex-Vault
```

2. **Install Flutter dependencies:**

```bash
flutter pub get
```

### Running the Mobile App

Start the development server and run the app on your connected device or emulator:

```bash
flutter run
```

For specific platforms:

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome

# Desktop (macOS/Windows/Linux)
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

**Key Entry Points:**

- `lib/main.dart` — App initialization with Hive database and Riverpod setup
- `lib/app. dart` — MaterialApp configuration with routing and theming
- `lib/core/routes/app_router.dart` — GoRouter route definitions (Splash, Onboarding, Auth, Home, Gallery, Preview, Upload Manager, Settings)

## Project Structure

```
Flex-Vault/
├── lib/                          # Flutter mobile app
│   ├── main.dart                # Entry point
│   ├── app.dart                 # App configuration & router
│   ├── core/                    # Shared utilities
│   │   └── routes/
│   │       └── app_router.dart  # Route definitions
│   └── features/                # Feature modules
│       ├── auth/
│       ├── home/
│       ├── gallery/
│       ├── upload/
│       └── settings/
├── backend/                     # AWS backend (Node.js + CDK)
│   ├── src/
│   │   ├── handlers/           # Lambda functions
│   │   ├── utils/              # Shared utilities
│   │   └── workers/            # Async job processors
│   └── infra/                  # Infrastructure as code
├── android/                    # Android platform code
├── ios/                        # iOS platform code
├── web/                        # Web platform code
├── windows/                    # Windows platform code
├── macos/                      # macOS platform code
├── linux/                      # Linux platform code
├── test/                       # Test suite
├── pubspec.yaml               # Dart/Flutter dependencies
└── analysis_options.yaml      # Lint rules
```

## Architecture Overview

### Mobile (Flutter)

| Layer | Technology | Details |
|-------|-----------|---------|
| **Routing** | GoRouter | Type-safe navigation with deep linking support |
| **State Management** | Riverpod | Dependency injection + reactive state (futures, streams) |
| **HTTP Client** | Dio | REST API communication with interceptors |
| **Local Storage** | Hive + Shared Preferences | Fast key-value store and user preferences |
| **UI Components** | Material 3 | Theme-aware widgets with pastel color palette |
| **ML On-Device** | Google ML Kit | Image labeling, text recognition (OCR) |
| **File Handling** | file_picker, image_picker | Cross-platform file selection |
| **Media** | flutter_image_compress | Image compression before upload |
| **Styling** | Google Fonts | Poppins, Inter, Roboto typography |

**Key Dependencies:**

```yaml
flutter_riverpod: ^2. 5.1    # State management
go_router: ^14.2.0          # Navigation
dio: ^5.6.0                 # HTTP client
file_picker: ^8.0.6         # File selection
image_picker: ^1.1.1        # Photo/video picker
google_mlkit_*: ^0.x        # ML Kit packages
hive: ^2.2.3                # Local database
shared_preferences: ^2. 2.3  # Preferences
google_sign_in: ^6.2.1      # OAuth integration
```

### Backend (AWS)

| Component | Service | Purpose |
|-----------|---------|---------|
| **Auth** | AWS Cognito | User management, JWT tokens, OAuth federation |
| **API** | API Gateway + Lambda | REST endpoints for file/folder operations |
| **Storage** | S3 + KMS | File uploads with encryption, lifecycle policies |
| **Metadata** | DynamoDB | User files, folders, uploads, async jobs |
| **Async Processing** | SQS + Lambda | Batch ML inference, duplicate detection |
| **ML Inference** | SageMaker / ECS | Heavy ML workloads (embeddings, OCR) |
| **Monitoring** | CloudWatch | Logs, alarms, performance metrics |

**DynamoDB Schema:**

```
Files
  PK: userId#fileId
  SK: fileId
  GSI1: folderId, createdAt
  GSI2: userId, status
  GSI3: userId, tag

Folders (PK: userId#folderId)
Uploads (PK: uploadId)  [TTL: 24h]
Jobs    (PK: jobId)     [for async tasks]
```

## Development

### Mobile Development

**Build & Run:**

```bash
# Get dependencies
flutter pub get

# Run on device
flutter run

# Run with build-time variables
flutter run --dart-define=FLEXVAULT_API_URL=https://api.your-domain.com

# Run tests
flutter test

# Build release APK/IPA
flutter build apk --release
flutter build ios --release
```

**Code Structure:**

- Feature modules follow a layered pattern: `screens/` → `providers/` → `services/`
- Models use `equatable` for value equality
- Services handle business logic (API calls, file operations, ML inference)
- Providers expose state via Riverpod (use `FutureProvider` for async, `StateNotifier` for mutable state)

### Backend Development

**Local Setup:**

```bash
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your values

# Run tests
npm test

# Run linter
npm run lint
```

**Key Lambda Handlers:**

- `src/handlers/auth/*` — Sign up, login, token refresh, OAuth
- `src/handlers/presignUpload. ts` — Generate S3 presigned upload URLs
- `src/handlers/presignDownload.ts` — Generate S3 presigned download URLs
- `src/handlers/metadataCallback.ts` — Process metadata confirmation
- `src/workers/batchInference.ts` — Async ML job processor

**Configuration:**

Store sensitive values in AWS Secrets Manager or environment variables:

```env
FLEXVAULT_BUCKET=your-s3-bucket
FLEXVAULT_TABLE=Files
COGNITO_USER_POOL_ID=us-east-1_xxx
COGNITO_CLIENT_ID=xxx
```

## Deployment

### Mobile

1. **iOS:** Use Xcode or `flutter build ios --release` → App Store Connect
2. **Android:** Generate signing key → `flutter build appbundle` → Google Play Console
3. **Web:** `flutter build web` → Host on Firebase, Vercel, or your CDN
4. **Desktop:** `flutter build windows/macos/linux` → Distribute native installers

### Backend

**Prerequisites:**

- AWS account with CLI configured
- Node.js 18+
- CDK/SAM installed (optional)

**Steps:**

1. **Provision infrastructure:**

```bash
cd backend/infra
# Using CDK
cdk deploy

# Or using SAM
sam deploy --guided
```

2. **Update mobile app:**

```bash
flutter run --dart-define=FLEXVAULT_API_URL=https://api. your-domain.com
```

3. **Configure custom domain & WAF** in API Gateway

**For detailed deployment guidance, see:**

- [Backend Deployment Guide](backend/infra/DEPLOYMENT.md)
- [DynamoDB Schema Reference](backend/infra/dynamodb-schema.md)

## Configuration

### Environment Variables

**Mobile (. env or build-time):**

```
FLEXVAULT_API_URL=https://api.flexvault.app
COGNITO_DOMAIN=https://auth.flexvault.app
GOOGLE_CLIENT_ID=xxx. apps.googleusercontent.com
```

**Backend (.env):**

```
AWS_REGION=us-east-1
FLEXVAULT_BUCKET=flexvault-prod
COGNITO_USER_POOL_ID=us-east-1_xxx
COGNITO_CLIENT_ID=xxx
```

## Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create a feature branch:**

```bash
git checkout -b feature/your-feature-name
```

3. **Make your changes** and test thoroughly
4. **Push to your fork** and **submit a pull request**

For detailed contribution guidelines, please refer to [CONTRIBUTING.md](CONTRIBUTING. md).

## Support

**Need Help?**

- 📖 **Issues & Discussions:** [GitHub Issues](https://github.com/asmitsaw/Flex-Vault/issues)
- 📋 **Documentation:** Check the `docs/` directory
- 🐛 **Bug Reports:** Please include Flutter/Dart version and device info

**Useful Commands:**

```bash
# Check Flutter setup
flutter doctor

# Analyze code
flutter analyze

# Format code
dart format .

# Run with verbose output
flutter run -v
```

## Roadmap

- [x] Mobile app with core features (Splash, Auth, Gallery, Upload)
- [x] AWS backend with Cognito, S3, DynamoDB
- [x] On-device ML (image labeling, OCR)
- [ ] Semantic search with embeddings
- [ ] Advanced duplicate detection
- [ ] Desktop app refinements
- [ ] Offline sync capability
- [ ] End-to-end encryption mode

## License

This project is licensed under the MIT License.  See [LICENSE](LICENSE) for details. 

## Authors

**Maintained by:** [asmitsaw](https://github. com/asmitsaw)

---

**Happy coding!  🚀**
