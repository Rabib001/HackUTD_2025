#!/bin/bash
#
# TEST DOCUMENT UPLOAD
# Tests automatic document processing with AWS Textract
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "Test Document Upload & Processing"
echo -e "==========================================${NC}"
echo ""

# Check if deployed
if [ ! -f "DEPLOYMENT_INFO.txt" ]; then
    echo -e "${YELLOW}⚠ DEPLOYMENT_INFO.txt not found${NC}"
    echo "Please run ./deploy.sh first"
    exit 1
fi

# Get bucket name
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubStorageStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentBucketName'].OutputValue" \
    --output text 2>/dev/null)

if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Could not find S3 bucket. Is the infrastructure deployed?"
    exit 1
fi

echo "Using S3 bucket: $BUCKET_NAME"
echo ""

# Check if test file exists
TEST_FILE="test-documents/sample-w9.pdf"

if [ ! -f "$TEST_FILE" ]; then
    echo "Creating test document..."
    mkdir -p test-documents

    # Create a simple test PDF using Python
    python3 << 'PYTHON_SCRIPT'
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
import os

os.makedirs("test-documents", exist_ok=True)

# Create a simple W-9 form
pdf = canvas.Canvas("test-documents/sample-w9.pdf", pagesize=letter)
pdf.setTitle("Sample W-9 Form")

# Title
pdf.setFont("Helvetica-Bold", 16)
pdf.drawString(200, 750, "Form W-9")
pdf.setFont("Helvetica", 10)
pdf.drawString(150, 730, "Request for Taxpayer Identification Number")

# Business name
pdf.setFont("Helvetica-Bold", 11)
pdf.drawString(50, 680, "Name:")
pdf.setFont("Helvetica", 11)
pdf.drawString(120, 680, "Acme Corporation")

# Business type
pdf.setFont("Helvetica-Bold", 11)
pdf.drawString(50, 650, "Business Type:")
pdf.setFont("Helvetica", 11)
pdf.drawString(160, 650, "C Corporation")

# TIN/EIN
pdf.setFont("Helvetica-Bold", 11)
pdf.drawString(50, 620, "TIN (EIN):")
pdf.setFont("Helvetica", 11)
pdf.drawString(120, 620, "12-3456789")

# Address
pdf.setFont("Helvetica-Bold", 11)
pdf.drawString(50, 590, "Address:")
pdf.setFont("Helvetica", 11)
pdf.drawString(120, 590, "123 Main Street")
pdf.drawString(120, 575, "New York, NY 10001")

# Signature line
pdf.line(50, 520, 300, 520)
pdf.setFont("Helvetica", 9)
pdf.drawString(50, 505, "Signature")

# Date
pdf.setFont("Helvetica-Bold", 11)
pdf.drawString(350, 520, "Date:")
pdf.setFont("Helvetica", 11)
pdf.drawString(400, 520, "11/09/2025")

pdf.save()
print("✓ Created test-documents/sample-w9.pdf")
PYTHON_SCRIPT

    # Check if Python reportlab is available, if not create a simple text file
    if [ ! -f "test-documents/sample-w9.pdf" ]; then
        echo "Form W-9 - Test Document" > "test-documents/sample-w9.txt"
        echo "Name: Acme Corporation" >> "test-documents/sample-w9.txt"
        echo "TIN: 12-3456789" >> "test-documents/sample-w9.txt"
        echo "Address: 123 Main Street, New York, NY 10001" >> "test-documents/sample-w9.txt"
        TEST_FILE="test-documents/sample-w9.txt"
        echo -e "${YELLOW}Note: Created text file instead of PDF (install reportlab for PDF)${NC}"
    fi
fi

echo -e "${GREEN}✓ Test file ready: $TEST_FILE${NC}"
echo ""

# Generate test IDs
VENDOR_ID="test-vendor-$(date +%s)"
DOC_ID="doc-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"

# Construct S3 key
S3_KEY="vendors/$VENDOR_ID/w9/$DOC_ID/$(basename $TEST_FILE)"

echo "Uploading document..."
echo "  Vendor ID: $VENDOR_ID"
echo "  Document ID: $DOC_ID"
echo "  S3 Key: $S3_KEY"
echo ""

# Upload file
aws s3 cp "$TEST_FILE" "s3://$BUCKET_NAME/$S3_KEY"

echo -e "${GREEN}✓ Document uploaded successfully!${NC}"
echo ""

# Get Lambda function name
LAMBDA_ARN=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubLambdaStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentProcessorArn'].OutputValue" \
    --output text)

FUNCTION_NAME=$(echo $LAMBDA_ARN | awk -F: '{print $NF}')

echo "Document should now be processing via AWS Textract..."
echo ""
echo "To monitor processing, run:"
echo "  aws logs tail /aws/lambda/$FUNCTION_NAME --follow"
echo ""

# Wait a moment and check logs
echo "Checking recent logs (last 30 seconds)..."
sleep 5

aws logs tail /aws/lambda/$FUNCTION_NAME --since 30s --format short 2>/dev/null | head -50 || echo "No logs yet (processing may take a few seconds)"

echo ""
echo -e "${BLUE}=========================================="
echo "Next Steps:"
echo -e "==========================================${NC}"
echo ""
echo "1. Monitor Lambda logs:"
echo "   aws logs tail /aws/lambda/$FUNCTION_NAME --follow"
echo ""
echo "2. Check S3 bucket:"
echo "   aws s3 ls s3://$BUCKET_NAME/vendors/ --recursive"
echo ""
echo "3. View in AWS Console:"
echo "   - Textract: https://console.aws.amazon.com/textract/home"
echo "   - CloudWatch: https://console.aws.amazon.com/cloudwatch/home"
echo ""
echo "Expected: Document status should change from 'processing' to 'extracted'"
echo ""
