#!/bin/bash
# Configure S3 event notifications to trigger DocumentProcessor Lambda
# This script must be run AFTER the CDK deployment completes

set -e  # Exit on error

echo "=========================================="
echo "S3 Event Notification Configuration"
echo "=========================================="
echo ""

# Get AWS region
REGION="${AWS_REGION:-us-east-1}"
echo "Using AWS Region: $REGION"
echo ""

# Step 1: Get the S3 bucket name from CloudFormation stack outputs
echo "[1/4] Fetching S3 bucket name from CloudFormation..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubStorageStack \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentBucketName'].OutputValue" \
    --output text 2>/dev/null)

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: Could not find S3 bucket. Make sure OnboardingHubStorageStack is deployed."
    exit 1
fi
echo "✓ Bucket: $BUCKET_NAME"
echo ""

# Step 2: Get the Lambda function ARN
echo "[2/4] Fetching DocumentProcessor Lambda ARN..."
LAMBDA_ARN=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubLambdaStack \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentProcessorArn'].OutputValue" \
    --output text 2>/dev/null)

if [ -z "$LAMBDA_ARN" ]; then
    echo "❌ Error: Could not find Lambda function. Make sure OnboardingHubLambdaStack is deployed."
    exit 1
fi
echo "✓ Lambda: $LAMBDA_ARN"
echo ""

# Step 3: Grant S3 permission to invoke Lambda
echo "[3/4] Granting S3 permission to invoke Lambda..."
aws lambda add-permission \
    --function-name $LAMBDA_ARN \
    --principal s3.amazonaws.com \
    --action lambda:InvokeFunction \
    --statement-id AllowS3Invoke \
    --source-arn "arn:aws:s3:::$BUCKET_NAME" \
    --region $REGION \
    2>/dev/null || echo "   (Permission may already exist - continuing...)"
echo "✓ Permission configured"
echo ""

# Step 4: Configure S3 event notifications
echo "[4/4] Configuring S3 event notifications..."

# Create notification configuration JSON
NOTIFICATION_CONFIG=$(cat <<EOF
{
  "LambdaFunctionConfigurations": [
    {
      "LambdaFunctionArn": "$LAMBDA_ARN",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            { "Name": "prefix", "Value": "vendors/" },
            { "Name": "suffix", "Value": ".pdf" }
          ]
        }
      }
    },
    {
      "LambdaFunctionArn": "$LAMBDA_ARN",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            { "Name": "prefix", "Value": "vendors/" },
            { "Name": "suffix", "Value": ".jpg" }
          ]
        }
      }
    },
    {
      "LambdaFunctionArn": "$LAMBDA_ARN",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            { "Name": "prefix", "Value": "vendors/" },
            { "Name": "suffix", "Value": ".jpeg" }
          ]
        }
      }
    },
    {
      "LambdaFunctionArn": "$LAMBDA_ARN",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            { "Name": "prefix", "Value": "vendors/" },
            { "Name": "suffix", "Value": ".png" }
          ]
        }
      }
    }
  ]
}
EOF
)

# Apply configuration
echo "$NOTIFICATION_CONFIG" | aws s3api put-bucket-notification-configuration \
    --bucket $BUCKET_NAME \
    --notification-configuration file:///dev/stdin \
    --region $REGION

echo "✓ Notification configuration applied"
echo ""

# Verify configuration
echo "Verifying configuration..."
aws s3api get-bucket-notification-configuration \
    --bucket $BUCKET_NAME \
    --region $REGION | python3 -m json.tool

echo ""
echo "=========================================="
echo "✅ S3 Event Notifications Configured!"
echo "=========================================="
echo ""
echo "Automatic document processing is now enabled for:"
echo "  • *.pdf files in vendors/ folder"
echo "  • *.jpg files in vendors/ folder"
echo "  • *.jpeg files in vendors/ folder"
echo "  • *.png files in vendors/ folder"
echo ""
echo "When a document is uploaded, the DocumentProcessor Lambda"
echo "will automatically extract data using AWS Textract."
echo ""
