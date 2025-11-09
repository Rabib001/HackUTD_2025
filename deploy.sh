#!/bin/bash
#
# ONE-COMMAND DEPLOYMENT SCRIPT
# Deploys entire Goldman Sachs Vendor Onboarding Hub infrastructure
#
# Usage: ./deploy.sh
#

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "Goldman Sachs Vendor Onboarding Hub"
echo "Automated Deployment Script"
echo -e "==========================================${NC}"
echo ""

# Function to print step headers
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ============================================
# STEP 0: Pre-flight Checks
# ============================================
print_step "STEP 0: Pre-flight Checks"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found. Please install: brew install awscli"
    exit 1
fi
print_success "AWS CLI installed"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js not found. Please install: brew install node"
    exit 1
fi
print_success "Node.js installed ($(node --version))"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 not found. Please install: brew install python3"
    exit 1
fi
print_success "Python 3 installed ($(python3 --version))"

# Check AWS credentials
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials are invalid or expired"
    echo ""
    echo "Please run: aws configure"
    echo "Or update your credentials in ~/.aws/credentials"
    echo ""
    echo "Need AWS credentials? Ask your team member who deployed before."
    exit 1
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="${AWS_REGION:-us-east-1}"
print_success "AWS credentials valid (Account: $AWS_ACCOUNT, Region: $AWS_REGION)"

# ============================================
# STEP 1: Install Python Dependencies
# ============================================
print_step "STEP 1: Installing Python CDK Dependencies"

cd infrastructure/cdk
echo "Installing from requirements.txt..."
pip3 install -r requirements.txt --quiet --disable-pip-version-check

print_success "Python dependencies installed"

# ============================================
# STEP 2: Bootstrap CDK (if needed)
# ============================================
print_step "STEP 2: CDK Bootstrap Check"

echo "Checking if CDK is already bootstrapped..."
BOOTSTRAP_STACK=$(aws cloudformation describe-stacks \
    --stack-name CDKToolkit \
    --region $AWS_REGION 2>/dev/null || echo "not-found")

if [[ "$BOOTSTRAP_STACK" == "not-found" ]]; then
    echo "Bootstrapping CDK (first-time setup)..."
    npx cdk bootstrap aws://$AWS_ACCOUNT/$AWS_REGION
    print_success "CDK bootstrapped"
else
    print_success "CDK already bootstrapped"
fi

# ============================================
# STEP 3: Deploy CDK Stacks
# ============================================
print_step "STEP 3: Deploying CDK Stacks (This may take 10-15 minutes)"

echo "Deploying all stacks..."
echo ""
print_warning "Deploying: VPC, Storage, Database, Lambda, API Gateway, Bastion"
echo ""

# Deploy all stacks
npx cdk deploy --all --require-approval never

print_success "All CDK stacks deployed successfully!"

# ============================================
# STEP 4: Get Stack Outputs
# ============================================
print_step "STEP 4: Retrieving Stack Outputs"

echo "Fetching deployed resources..."

# Get S3 bucket name
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubStorageStack \
    --region $AWS_REGION \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentBucketName'].OutputValue" \
    --output text)
print_success "S3 Bucket: $BUCKET_NAME"

# Get API Gateway URL
API_URL=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubApiStack \
    --region $AWS_REGION \
    --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" \
    --output text)
print_success "API URL: $API_URL"

# Get Lambda ARN
LAMBDA_ARN=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubLambdaStack \
    --region $AWS_REGION \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentProcessorArn'].OutputValue" \
    --output text)
print_success "Document Processor: $LAMBDA_ARN"

# Get Database endpoint
DB_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubDatabaseStack \
    --region $AWS_REGION \
    --query "Stacks[0].Outputs[?OutputKey=='DatabaseEndpoint'].OutputValue" \
    --output text 2>/dev/null || echo "N/A")
print_success "Database: $DB_ENDPOINT"

# ============================================
# STEP 5: Configure S3 Event Notifications
# ============================================
print_step "STEP 5: Configuring S3 Event Notifications"

cd ../../infrastructure/scripts

echo "Running S3 notification configuration script..."
./configure_s3_notifications.sh

print_success "S3 event notifications configured!"

# ============================================
# STEP 6: Initialize Database
# ============================================
print_step "STEP 6: Initializing Database Schema"

echo "Invoking database initialization Lambda..."

DB_INIT_FUNCTION=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubLambdaStack \
    --region $AWS_REGION \
    --query "Stacks[0].Outputs[?OutputKey=='DbInitHandlerArn'].OutputValue" \
    --output text)

aws lambda invoke \
    --function-name $DB_INIT_FUNCTION \
    --region $AWS_REGION \
    --payload '{}' \
    /tmp/db-init-response.json > /dev/null

DB_INIT_RESULT=$(cat /tmp/db-init-response.json)
echo "Database initialization result:"
echo "$DB_INIT_RESULT" | python3 -m json.tool

print_success "Database schema and seed data created!"

# ============================================
# STEP 7: Configure Frontend
# ============================================
print_step "STEP 7: Configuring Frontend"

cd ../../frontend

echo "Creating .env file with API URL..."
cat > .env <<EOF
# Auto-generated by deploy.sh on $(date)
VITE_API_URL=$API_URL
EOF

print_success "Frontend .env file created"

# ============================================
# STEP 8: Install Frontend Dependencies
# ============================================
print_step "STEP 8: Installing Frontend Dependencies"

if [ ! -d "node_modules" ]; then
    echo "Installing npm packages (this may take a few minutes)..."
    npm install
    print_success "Frontend dependencies installed"
else
    print_success "Frontend dependencies already installed"
fi

# ============================================
# DEPLOYMENT COMPLETE
# ============================================
echo ""
echo -e "${GREEN}=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo -e "==========================================${NC}"
echo ""

echo -e "${BLUE}📋 Deployment Summary:${NC}"
echo ""
echo "  🗄️  S3 Bucket:        $BUCKET_NAME"
echo "  🚀 API Gateway:      $API_URL"
echo "  🤖 Document Processor: $(echo $LAMBDA_ARN | awk -F: '{print $NF}')"
echo "  💾 Database:         $DB_ENDPOINT"
echo ""

echo -e "${BLUE}🎯 Next Steps:${NC}"
echo ""
echo "  1. Start the frontend:"
echo "     cd frontend"
echo "     npm run dev"
echo ""
echo "  2. Open browser to http://localhost:5173"
echo ""
echo "  3. Test document upload:"
echo "     - Register as a vendor"
echo "     - Upload a W-9 PDF"
echo "     - Watch Textract extract data automatically!"
echo ""

echo -e "${BLUE}🧪 Test Commands:${NC}"
echo ""
echo "  # Upload test document via CLI"
echo "  aws s3 cp test.pdf s3://$BUCKET_NAME/vendors/test-123/w9/doc-456/test.pdf"
echo ""
echo "  # Watch Lambda logs"
echo "  FUNCTION=\$(echo $LAMBDA_ARN | awk -F: '{print \$NF}')"
echo "  aws logs tail /aws/lambda/\$FUNCTION --follow"
echo ""

echo -e "${BLUE}📚 Documentation:${NC}"
echo ""
echo "  • Quick Start:    QUICK_START_DOCUMENT_PROCESSING.md"
echo "  • Full Guide:     infrastructure/DEPLOY_DOCUMENT_PROCESSING.md"
echo "  • Deployment Log: infrastructure/DEPLOYMENT_CHECKLIST.md"
echo ""

echo -e "${GREEN}🏆 Ready for hackathon demo!${NC}"
echo ""

# Save deployment info
cd ..
cat > DEPLOYMENT_INFO.txt <<EOF
Deployment completed at: $(date)
AWS Account: $AWS_ACCOUNT
AWS Region: $AWS_REGION

S3 Bucket: $BUCKET_NAME
API Gateway: $API_URL
Lambda ARN: $LAMBDA_ARN
Database: $DB_ENDPOINT

Frontend URL: http://localhost:5173
Frontend API: $API_URL
EOF

print_success "Deployment info saved to DEPLOYMENT_INFO.txt"

echo ""
echo -e "${YELLOW}⚠️  Don't forget to:${NC}"
echo "  • Test document upload end-to-end"
echo "  • Record a backup demo video"
echo "  • Practice your presentation"
echo ""
