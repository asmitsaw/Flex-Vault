# FlexVault Backend Deployment Guide

This guide covers deploying the FlexVault backend infrastructure using AWS CDK or SAM.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Node.js 20+ installed
- AWS CDK CLI installed (`npm install -g aws-cdk`) OR AWS SAM CLI installed
- TypeScript installed globally or locally

## Option 1: Deploy with AWS CDK

### Setup

1. Install CDK dependencies:
```bash
cd backend/infra
npm install aws-cdk-lib constructs
```

2. Build the TypeScript code:
```bash
cd ../..
npm run build
```

3. Bootstrap CDK (first time only):
```bash
cdk bootstrap
```

### Deploy

```bash
cd backend/infra
cdk deploy
```

### Outputs

After deployment, CDK will output:
- `UserPoolId` - Cognito User Pool ID
- `UserPoolClientId` - Cognito Client ID
- `ApiUrl` - API Gateway endpoint URL
- `BucketName` - S3 bucket name

## Option 2: Deploy with AWS SAM

### Setup

1. Build the TypeScript code:
```bash
npm run build
```

2. Package and deploy:
```bash
sam build
sam deploy --guided
```

The `--guided` flag will prompt you for:
- Stack name
- AWS Region
- Parameter overrides
- Confirmation of changes

## Environment Variables

After deployment, update your `.env` file or Lambda environment variables with:

```env
AWS_REGION=us-east-1
COGNITO_USER_POOL_ID=<from CDK output>
COGNITO_CLIENT_ID=<from CDK output>
GOOGLE_CLIENT_ID=<google-oauth-client-id>
GOOGLE_AUTH_SECRET=<shared-secret-used-for-deriving-passwords>
FLEXVAULT_BUCKET=<from CDK output>
FLEXVAULT_TABLE=flexvault-files
FLEXVAULT_UPLOAD_TABLE=flexvault-uploads
FLEXVAULT_JOBS_QUEUE=<SQS queue URL>
FLEXVAULT_PRESIGN_EXPIRY=900
```

## API Endpoints

### Public Endpoints (No Auth Required)

- `POST /auth/signup` - User registration
- `POST /auth/login` - User login
- `POST /auth/google` - Sign in with Google OAuth (exchanges ID token for Cognito tokens)
- `POST /auth/confirm-signup` - Confirm email verification
- `POST /auth/refresh-token` - Refresh access token
- `POST /auth/forgot-password` - Initiate password reset
- `POST /auth/reset-password` - Complete password reset

### Protected Endpoints (Require JWT Token)

- `GET /me` - Get current user info
- `POST /upload/presign` - Get presigned upload URL
- `GET /download/presign?key=<file-key>` - Get presigned download URL

## Testing the API

### Sign Up
```bash
curl -X POST https://<api-url>/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "name": "John Doe"
  }'
```

### Login
```bash
curl -X POST https://<api-url>/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'
```

### Google Sign-In
```bash
curl -X POST https://<api-url>/auth/google \
  -H "Content-Type: application/json" \
  -d '{
    "idToken": "<google-id-token>"
  }'
```

### Get User Info (Protected)
```bash
curl -X GET https://<api-url>/me \
  -H "Authorization: Bearer <access-token>"
```

## Troubleshooting

### Lambda Function Errors

Check CloudWatch Logs:
```bash
aws logs tail /aws/lambda/flexvault-auth-login --follow
```

### Cognito Issues

Verify user pool configuration:
```bash
aws cognito-idp describe-user-pool --user-pool-id <pool-id>
```

### API Gateway CORS

If you encounter CORS issues, ensure the API Gateway CORS configuration matches your frontend origin.

## Cleanup

To remove all resources:

**CDK:**
```bash
cdk destroy
```

**SAM:**
```bash
sam delete
```

## Next Steps

1. Configure custom domain for API Gateway
2. Set up WAF rules for API protection
3. Configure CloudWatch alarms for monitoring
4. Set up CI/CD pipeline for automated deployments


