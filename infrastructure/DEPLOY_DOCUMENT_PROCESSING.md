# Document Processing Deployment Guide

## Overview

This guide explains how to deploy and configure **automatic document processing** using AWS Textract. Once configured, any document uploaded to the S3 bucket will automatically trigger the DocumentProcessor Lambda function to extract data.

## Prerequisites

- AWS CLI installed and configured with valid credentials
- Python 3.11+ installed
- AWS CDK CLI installed (`npm install -g aws-cdk`)
- AWS account with sufficient permissions

## Deployment Steps

### Step 1: Configure AWS Credentials

```bash
# Configure your AWS credentials
aws configure

# Verify credentials work
aws sts get-caller-identity
```

### Step 2: Install Python Dependencies

```bash
cd infrastructure/cdk
pip3 install -r requirements.txt
```

### Step 3: Deploy CDK Stacks

```bash
# Bootstrap CDK (first time only)
cdk bootstrap

# Deploy all stacks (or deploy individually)
cdk deploy --all --require-approval never

# This will deploy:
# 1. OnboardingHubVpcStack
# 2. OnboardingHubStorageStack
# 3. OnboardingHubDatabaseStack
# 4. OnboardingHubLambdaStack
# 5. OnboardingHubApiStack
# 6. OnboardingHubBastionStack (optional)
```

### Step 4: Configure S3 Event Notifications

**IMPORTANT**: This step must be run AFTER the CDK deployment completes.

Due to CDK circular dependency limitations, S3 event notifications must be configured via a post-deployment script:

```bash
cd infrastructure/scripts

# Run the configuration script
./configure_s3_notifications.sh

# The script will:
# 1. Get the S3 bucket name from CloudFormation
# 2. Get the DocumentProcessor Lambda ARN
# 3. Grant S3 permission to invoke the Lambda
# 4. Configure event notifications for PDF, JPG, JPEG, PNG uploads
```

### Step 5: Verify Configuration

After running the script, you should see output like:

```json
{
    "LambdaFunctionConfigurations": [
        {
            "LambdaFunctionArn": "arn:aws:lambda:us-east-1:...",
            "Events": ["s3:ObjectCreated:*"],
            "Filter": {
                "Key": {
                    "FilterRules": [
                        {"Name": "prefix", "Value": "vendors/"},
                        {"Name": "suffix", "Value": ".pdf"}
                    ]
                }
            }
        }
        // ... more configurations for .jpg, .jpeg, .png
    ]
}
```

## Testing Document Processing

### Test 1: Upload via AWS CLI

```bash
# Get the bucket name
BUCKET=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubStorageStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentBucketName'].OutputValue" \
    --output text)

# Upload a test PDF (create a dummy vendors folder structure)
aws s3 cp test-w9.pdf s3://$BUCKET/vendors/test-vendor-123/w9/doc-456/test-w9.pdf
```

### Test 2: Monitor Lambda Execution

```bash
# Get the Lambda function name
FUNCTION=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubLambdaStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentProcessorArn'].OutputValue" \
    --output text | awk -F: '{print $NF}')

# Watch CloudWatch logs
aws logs tail /aws/lambda/$FUNCTION --follow
```

You should see:

```
Processing document: {"Records": [{"s3": {"bucket": {"name": "..."}, "object": {"key": "vendors/..."}}}]}
Starting Textract analysis for w9
Textract job started: xyz123...
Textract job completed successfully
Document doc-456 updated with status: extracted
```

### Test 3: Check Database

```bash
# Connect to the database via bastion
# (See DEPLOYMENT_CHECKLIST.md for bastion connection details)

# Query extracted document data
SELECT id, vendor_id, document_type, status, extracted_data
FROM documents
WHERE id = 'doc-456';
```

You should see:
- `status`: `'extracted'`
- `extracted_data`: JSON with Textract results

## How It Works

### File Naming Convention

The S3 key must follow this structure for automatic processing:

```
vendors/{vendor_id}/{document_type}/{document_id}/{filename}
```

Example:
```
vendors/550e8400-e29b-41d4-a716-446655440000/w9/123e4567-e89b-12d3-a456-426614174000/company-w9.pdf
```

### Supported File Types

- `.pdf` - PDF documents
- `.jpg` - JPEG images
- `.jpeg` - JPEG images
- `.png` - PNG images

### Document Types Supported

The DocumentProcessor can extract specific fields from:

- `w9` - W-9 tax forms (TIN, business name, address, signature)
- `insurance` - Insurance certificates (policy numbers, coverage, dates)
- `diversity_cert` - Diversity certifications (MBE, WBE, DBE)
- `soc2` - SOC 2 reports (auditor, opinion, controls)
- `iso_cert` - ISO certifications (standard, scope, dates)
- `bcp` - Business continuity plans (RTO, RPO, backup location)

### Processing Flow

1. **Upload**: Document uploaded to S3 at `vendors/{vendor_id}/{doc_type}/{doc_id}/{file}`
2. **Trigger**: S3 event notification invokes DocumentProcessor Lambda
3. **Parse**: Lambda extracts vendor_id, document_type, document_id from S3 key
4. **Update DB**: Document status set to `'processing'`
5. **Textract**: Lambda calls AWS Textract StartDocumentAnalysis
6. **Poll**: Lambda polls GetDocumentAnalysis until job completes (max 5 minutes)
7. **Extract**: Parse Textract response for document-specific fields
8. **Store**: Update database with extracted_data JSON and status `'extracted'`
9. **Complete**: Return success response

## Troubleshooting

### Event notifications not triggering

```bash
# Check notification configuration
BUCKET=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubStorageStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentBucketName'].OutputValue" \
    --output text)

aws s3api get-bucket-notification-configuration --bucket $BUCKET
```

### Lambda permission issues

```bash
# Check if S3 has permission to invoke Lambda
FUNCTION_ARN=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubLambdaStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentProcessorArn'].OutputValue" \
    --output text)

aws lambda get-policy --function-name $FUNCTION_ARN
```

Look for:
```json
{
  "Statement": [
    {
      "Sid": "AllowS3Invoke",
      "Effect": "Allow",
      "Principal": {"Service": "s3.amazonaws.com"},
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:...",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:s3:::bucket-name"
        }
      }
    }
  ]
}
```

### Textract timeouts

The Lambda has a 5-minute timeout. If Textract jobs take longer:

1. Check document size (large PDFs may take longer)
2. Increase timeout in `lambda_stack.py` line 225:
   ```python
   timeout=Duration.seconds(600),  # Increase to 10 minutes
   ```
3. Redeploy: `cdk deploy OnboardingHubLambdaStack`

### Check Textract job status

```bash
# Get job ID from CloudWatch logs, then:
aws textract get-document-analysis --job-id <job-id>
```

## Cost Optimization

### Textract Pricing

- $1.50 per 1,000 pages for Document Analysis
- First 1M pages/month included in AWS Free Tier (new accounts)

### Lambda Pricing

- $0.20 per 1M requests
- $0.0000166667 per GB-second
- 1M requests + 400,000 GB-seconds free tier/month

### Estimated Costs

For hackathon demo with ~50 test documents:
- **Textract**: ~$0.08 (50 pages × $1.50/1000)
- **Lambda**: ~$0.00 (within free tier)
- **S3**: ~$0.00 (within free tier)

**Total demo cost: < $0.10**

## Security Notes

- Documents are encrypted at rest using customer-managed KMS key
- Documents are encrypted in transit using TLS 1.2+
- Lambda runs in private VPC subnets (no internet access)
- S3 bucket blocks all public access
- Database credentials stored in AWS Secrets Manager

## Next Steps

After successful deployment:

1. **Update Frontend**: Add API endpoint URL to frontend `.env` file
2. **Test End-to-End**: Upload via frontend → Verify Textract extraction
3. **Initialize Database**: Run db_init Lambda to create schema and seed data
4. **Demo Prep**: Upload sample documents for demo

## Support

For issues:
- Check CloudWatch Logs: `/aws/lambda/OnboardingHubLambdaStack-DocumentProcessor*`
- Review CDK deployment errors: `cdk deploy --verbose`
- Verify IAM permissions for Textract, S3, Lambda

---

**Status**: ✅ Ready for deployment after AWS credentials are configured
