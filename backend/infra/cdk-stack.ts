import * as cdk from 'aws-cdk-lib';
import * as cognito from 'aws-cdk-lib/aws-cognito';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3n from 'aws-cdk-lib/aws-s3-notifications';
import * as lambdaEventSources from 'aws-cdk-lib/aws-lambda-event-sources';
import { Construct } from 'constructs';

export class FlexVaultStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Cognito User Pool
    const userPool = new cognito.UserPool(this, 'FlexVaultUserPool', {
      userPoolName: 'flexvault-users',
      signInAliases: {
        email: true,
      },
      autoVerify: {
        email: true,
      },
      passwordPolicy: {
        minLength: 8,
        requireLowercase: true,
        requireUppercase: true,
        requireDigits: true,
        requireSymbols: false,
      },
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    const userPoolClient = userPool.addClient('FlexVaultClient', {
      userPoolClientName: 'flexvault-mobile-client',
      generateSecret: false,
      authFlows: {
        userPassword: true,
        userSrp: true,
      },
      refreshTokenValidity: cdk.Duration.days(30),
      accessTokenValidity: cdk.Duration.hours(1),
      idTokenValidity: cdk.Duration.hours(1),
    });

    // S3 Bucket for file storage
    const bucket = new s3.Bucket(this, 'FlexVaultBucket', {
      bucketName: `flexvault-files-${this.account}-${this.region}`,
      encryption: s3.BucketEncryption.S3_MANAGED,
      versioned: true,
      lifecycleRules: [
        {
          id: 'DeleteTempUploads',
          prefix: 'temp/',
          expiration: cdk.Duration.days(1),
        },
      ],
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    // DynamoDB Tables
    const filesTable = new dynamodb.Table(this, 'FilesTable', {
      tableName: 'flexvault-files',
      partitionKey: { name: 'pk', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'sk', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    filesTable.addGlobalSecondaryIndex({
      indexName: 'GSI1',
      partitionKey: { name: 'folderId', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'createdAt', type: dynamodb.AttributeType.STRING },
    });

    filesTable.addGlobalSecondaryIndex({
      indexName: 'GSI2',
      partitionKey: { name: 'userId', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'status', type: dynamodb.AttributeType.STRING },
    });

    filesTable.addGlobalSecondaryIndex({
      indexName: 'GSI3',
      partitionKey: { name: 'userId', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'tag', type: dynamodb.AttributeType.STRING },
    });

    const foldersTable = new dynamodb.Table(this, 'FoldersTable', {
      tableName: 'flexvault-folders',
      partitionKey: { name: 'pk', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'sk', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    const uploadsTable = new dynamodb.Table(this, 'UploadsTable', {
      tableName: 'flexvault-uploads',
      partitionKey: { name: 'uploadId', type: dynamodb.AttributeType.STRING },
      timeToLiveAttribute: 'ttl',
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    const jobsTable = new dynamodb.Table(this, 'JobsTable', {
      tableName: 'flexvault-jobs',
      partitionKey: { name: 'jobId', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    // SQS Queue for async jobs
    const jobsQueue = new sqs.Queue(this, 'JobsQueue', {
      queueName: 'flexvault-jobs',
      visibilityTimeout: cdk.Duration.minutes(5),
      retentionPeriod: cdk.Duration.days(14),
    });

    // Lambda execution role
    const lambdaRole = new iam.Role(this, 'LambdaExecutionRole', {
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName(
          'service-role/AWSLambdaBasicExecutionRole',
        ),
      ],
    });

    // Grant permissions
    bucket.grantReadWrite(lambdaRole);
    filesTable.grantReadWriteData(lambdaRole);
    foldersTable.grantReadWriteData(lambdaRole);
    uploadsTable.grantReadWriteData(lambdaRole);
    jobsTable.grantReadWriteData(lambdaRole);
    jobsQueue.grantSendMessages(lambdaRole);
    userPool.grant(
      lambdaRole,
      'cognito-idp:AdminInitiateAuth',
      'cognito-idp:InitiateAuth',
      'cognito-idp:SignUp',
      'cognito-idp:ConfirmSignUp',
      'cognito-idp:ForgotPassword',
      'cognito-idp:ConfirmForgotPassword',
      'cognito-idp:GetUser',
      'cognito-idp:AdminGetUser',
    );

    // Lambda functions
    const authHandlers = {
      signup: 'signup',
      login: 'login',
      confirmSignup: 'confirmSignup',
      refreshToken: 'refreshToken',
      forgotPassword: 'forgotPassword',
      resetPassword: 'resetPassword',
      me: 'me',
      google: 'googleSignIn',
    };

    const lambdas: Record<string, lambda.Function> = {};

    for (const [name, handlerName] of Object.entries(authHandlers)) {
      lambdas[name] = new lambda.Function(this, `Auth${name.charAt(0).toUpperCase() + name.slice(1)}Lambda`, {
        functionName: `flexvault-auth-${name}`,
        runtime: lambda.Runtime.NODEJS_20_X,
        handler: `handlers/auth/${handlerName}.handler`,
        code: lambda.Code.fromAsset('dist'),
        role: lambdaRole,
        environment: {
          AWS_REGION: this.region,
          COGNITO_USER_POOL_ID: userPool.userPoolId,
          COGNITO_CLIENT_ID: userPoolClient.userPoolClientId,
          GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID ?? '',
          GOOGLE_AUTH_SECRET: process.env.GOOGLE_AUTH_SECRET ?? '',
        },
        timeout: cdk.Duration.seconds(30),
      });
    }

    // API Gateway handlers
    const presignUploadLambda = new lambda.Function(this, 'PresignUploadLambda', {
      functionName: 'flexvault-presign-upload',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'handlers/presignUpload.handler',
      code: lambda.Code.fromAsset('dist'),
      role: lambdaRole,
      environment: {
        AWS_REGION: this.region,
        FLEXVAULT_BUCKET: bucket.bucketName,
        FLEXVAULT_UPLOAD_TABLE: uploadsTable.tableName,
        FLEXVAULT_PRESIGN_EXPIRY: '900',
      },
    });

    const presignDownloadLambda = new lambda.Function(this, 'PresignDownloadLambda', {
      functionName: 'flexvault-presign-download',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'handlers/presignDownload.handler',
      code: lambda.Code.fromAsset('dist'),
      role: lambdaRole,
      environment: {
        AWS_REGION: this.region,
        FLEXVAULT_BUCKET: bucket.bucketName,
        FLEXVAULT_TABLE: filesTable.tableName,
      },
    });

    const metadataCallbackLambda = new lambda.Function(this, 'MetadataCallbackLambda', {
      functionName: 'flexvault-metadata-callback',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'handlers/metadataCallback.handler',
      code: lambda.Code.fromAsset('dist'),
      role: lambdaRole,
      environment: {
        AWS_REGION: this.region,
        FLEXVAULT_TABLE: filesTable.tableName,
        FLEXVAULT_JOBS_QUEUE: jobsQueue.queueUrl,
      },
    });

    const batchInferenceLambda = new lambda.Function(this, 'BatchInferenceLambda', {
      functionName: 'flexvault-batch-inference',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'workers/batchInference.handler',
      code: lambda.Code.fromAsset('dist'),
      role: lambdaRole,
      environment: {
        AWS_REGION: this.region,
        FLEXVAULT_TABLE: filesTable.tableName,
      },
    });

    jobsQueue.grantConsumeMessages(batchInferenceLambda);

    // S3 Event trigger for metadata callback
    bucket.addEventNotification(
      s3.EventType.OBJECT_CREATED,
      new s3n.LambdaDestination(metadataCallbackLambda),
    );

    // SQS Event Source for batch inference
    batchInferenceLambda.addEventSource(
      new lambdaEventSources.SqsEventSource(jobsQueue),
    );

    // API Gateway
    const authorizer = new apigateway.CognitoUserPoolsAuthorizer(
      this,
      'CognitoAuthorizer',
      {
        cognitoUserPools: [userPool],
        identitySource: 'method.request.header.Authorization',
      },
    );

    const api = new apigateway.RestApi(this, 'FlexVaultApi', {
      restApiName: 'FlexVault API',
      description: 'API for FlexVault cloud storage',
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS,
        allowHeaders: ['Content-Type', 'Authorization'],
      },
    });

    // Auth routes (no auth required)
    const authResource = api.root.addResource('auth');
    authResource.addResource('signup').addMethod('POST', new apigateway.LambdaIntegration(lambdas.signup));
    authResource.addResource('login').addMethod('POST', new apigateway.LambdaIntegration(lambdas.login));
    authResource.addResource('confirm-signup').addMethod('POST', new apigateway.LambdaIntegration(lambdas.confirmSignup));
    authResource.addResource('refresh-token').addMethod('POST', new apigateway.LambdaIntegration(lambdas.refreshToken));
    authResource.addResource('forgot-password').addMethod('POST', new apigateway.LambdaIntegration(lambdas.forgotPassword));
    authResource.addResource('reset-password').addMethod('POST', new apigateway.LambdaIntegration(lambdas.resetPassword));
    authResource.addResource('google').addMethod('POST', new apigateway.LambdaIntegration(lambdas.google));

    // Protected routes
    const meResource = api.root.addResource('me');
    meResource.addMethod('GET', new apigateway.LambdaIntegration(lambdas.me), {
      authorizer,
    });

    const uploadResource = api.root.addResource('upload');
    uploadResource.addResource('presign').addMethod('POST', new apigateway.LambdaIntegration(presignUploadLambda), {
      authorizer,
    });

    const downloadResource = api.root.addResource('download');
    downloadResource.addResource('presign').addMethod('GET', new apigateway.LambdaIntegration(presignDownloadLambda), {
      authorizer,
    });

    // Outputs
    new cdk.CfnOutput(this, 'UserPoolId', {
      value: userPool.userPoolId,
    });

    new cdk.CfnOutput(this, 'UserPoolClientId', {
      value: userPoolClient.userPoolClientId,
    });

    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
    });

    new cdk.CfnOutput(this, 'BucketName', {
      value: bucket.bucketName,
    });
  }
}

