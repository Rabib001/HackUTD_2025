#!/bin/bash
#
# UPDATE AWS CREDENTIALS
# Quick script to update AWS credentials for deployment
#

set -e

echo "=========================================="
echo "AWS Credentials Setup"
echo "=========================================="
echo ""

echo "Your current AWS credentials are expired or invalid."
echo ""
echo "You need to update them to deploy the infrastructure."
echo ""

# Check if someone else has deployed
echo "Looking for existing deployment..."
if [ -f "infrastructure/database/init_database.py" ]; then
    echo ""
    echo "Found evidence of previous deployment!"
    echo ""
    echo "Checking init_database.py for hints..."
    PREV_ACCOUNT=$(grep -o "560271561576" infrastructure/database/init_database.py 2>/dev/null || echo "")

    if [ -n "$PREV_ACCOUNT" ]; then
        echo "Previous deployment used AWS Account: $PREV_ACCOUNT"
        echo ""
        echo "Ask your team member who deployed this for their credentials, or:"
    fi
fi

echo ""
echo "Option 1: Use AWS Configure (Interactive)"
echo "  aws configure"
echo ""
echo "Option 2: Manual Update (Edit ~/.aws/credentials)"
echo "  nano ~/.aws/credentials"
echo ""
echo "Option 3: Use Environment Variables (Temporary)"
echo "  export AWS_ACCESS_KEY_ID='your-key'"
echo "  export AWS_SECRET_ACCESS_KEY='your-secret'"
echo "  export AWS_REGION='us-east-1'"
echo ""

read -p "Do you want to run 'aws configure' now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Running AWS Configure..."
    echo ""
    echo "You'll need:"
    echo "  1. AWS Access Key ID"
    echo "  2. AWS Secret Access Key"
    echo "  3. Default region (use: us-east-1)"
    echo "  4. Default output format (use: json)"
    echo ""

    aws configure

    echo ""
    echo "Testing credentials..."
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
        echo "✓ Credentials valid!"
        echo "  Account: $ACCOUNT"
        echo ""
        echo "You can now run: ./deploy.sh"
    else
        echo "✗ Credentials still invalid. Please try again."
    fi
else
    echo ""
    echo "No problem. Update credentials manually, then run:"
    echo "  ./deploy.sh"
fi

echo ""
