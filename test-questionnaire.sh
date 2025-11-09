#!/bin/bash
#
# TEST QUESTIONNAIRE API
# Tests the KY3P questionnaire submission endpoint
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "Test Questionnaire Submission"
echo -e "==========================================${NC}"
echo ""

# Get API URL
if [ -f "DEPLOYMENT_INFO.txt" ]; then
    API_URL=$(grep "API Gateway:" DEPLOYMENT_INFO.txt | awk '{print $3}')
else
    echo -e "${YELLOW}DEPLOYMENT_INFO.txt not found${NC}"
    echo "Getting API URL from CloudFormation..."
    API_URL=$(aws cloudformation describe-stacks \
        --stack-name OnboardingHubApiStack \
        --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" \
        --output text 2>/dev/null)
fi

if [ -z "$API_URL" ]; then
    echo -e "${RED}Error: Could not find API URL${NC}"
    echo "Please run ./deploy.sh first"
    exit 1
fi

echo -e "${GREEN}API URL: $API_URL${NC}"
echo ""

# Create test vendor first if needed
echo "Step 1: Creating test vendor..."
VENDOR_RESPONSE=$(curl -s -X POST "${API_URL}/vendors" \
    -H "Content-Type: application/json" \
    -d '{
        "company_name": "Test Corp for Questionnaire",
        "ein": "12-3456789",
        "contact_email": "questionnaire-test@testcorp.com",
        "contact_phone": "555-0123",
        "address": "123 Test St, Test City, TC 12345"
    }')

VENDOR_ID=$(echo $VENDOR_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin).get('vendor_id', ''))" 2>/dev/null || echo "")

if [ -z "$VENDOR_ID" ]; then
    echo -e "${YELLOW}Could not create new vendor, trying existing vendor...${NC}"
    # Use a test vendor ID (you may need to replace this)
    VENDOR_ID="test-vendor-123"
    echo "Using vendor ID: $VENDOR_ID"
else
    echo -e "${GREEN}✓ Vendor created: $VENDOR_ID${NC}"
fi
echo ""

# Submit questionnaire
echo "Step 2: Submitting KY3P questionnaire..."

RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST \
    "${API_URL}/vendors/${VENDOR_ID}/questionnaire" \
    -H "Content-Type: application/json" \
    -d '{
        "business_description": "We provide cloud-based software solutions for enterprise resource planning",
        "years_in_business": 5,
        "number_of_employees": 150,
        "annual_revenue": "10M-50M",
        "compliance_certifications": ["ISO 27001", "SOC 2", "GDPR Compliant"],
        "data_privacy_compliance": "We maintain GDPR and CCPA compliance with regular audits and data protection officer oversight",
        "sanctions_screening": "We screen all customers and partners against OFAC and UN sanctions lists using automated tools",
        "litigation_history": "No material litigation in the past 5 years",
        "security_certifications": ["ISO 27001", "SOC 2 Type II"],
        "incident_response_plan": "We have a documented incident response plan with 24/7 SOC monitoring and quarterly tabletop exercises",
        "data_encryption": "AES-256 encryption for data at rest, TLS 1.3 for data in transit",
        "access_controls": "Role-based access control with MFA required for all systems, regular access reviews",
        "financial_health": "Positive cash flow for 3 consecutive years, no outstanding debt, credit rating AA-",
        "insurance_coverage": "General liability $5M, Cyber liability $10M, E&O $2M, all policies current",
        "backup_procedures": "Daily incremental backups, weekly full backups, 99.9% RTO of 4 hours, RPO of 1 hour",
        "esg_policies": "Comprehensive ESG framework aligned with UN SDGs, published annual sustainability report",
        "diversity_initiatives": "40% diverse workforce, supplier diversity program, DEI training for all employees",
        "environmental_commitments": "Carbon neutral operations by 2025, 100% renewable energy by 2024, LEED certified offices"
    }')

# Extract HTTP status
HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d':' -f2)
BODY=$(echo "$RESPONSE" | sed -e 's/HTTP_STATUS\:.*//g')

echo "Response status: $HTTP_STATUS"
echo ""

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo -e "${GREEN}✓ Questionnaire submitted successfully!${NC}"
    echo ""
    echo "Response:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    echo ""

    # Try to get the questionnaire back
    echo "Step 3: Retrieving questionnaire..."
    GET_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
        "${API_URL}/vendors/${VENDOR_ID}/questionnaire")

    GET_STATUS=$(echo "$GET_RESPONSE" | grep "HTTP_STATUS" | cut -d':' -f2)
    GET_BODY=$(echo "$GET_RESPONSE" | sed -e 's/HTTP_STATUS\:.*//g')

    if [ "$GET_STATUS" -eq 200 ]; then
        echo -e "${GREEN}✓ Questionnaire retrieved successfully!${NC}"
        echo ""
        echo "Retrieved questionnaire:"
        echo "$GET_BODY" | python3 -m json.tool 2>/dev/null || echo "$GET_BODY"
    else
        echo -e "${YELLOW}⚠ Could not retrieve questionnaire (status: $GET_STATUS)${NC}"
        echo "$GET_BODY"
    fi
else
    echo -e "${RED}✗ Questionnaire submission failed!${NC}"
    echo ""
    echo "Error response:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
fi

echo ""
echo -e "${BLUE}=========================================="
echo "Test Summary"
echo -e "==========================================${NC}"
echo ""
echo "Vendor ID: $VENDOR_ID"
echo "API URL: ${API_URL}/vendors/${VENDOR_ID}/questionnaire"
echo ""

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo -e "${GREEN}Status: SUCCESS ✓${NC}"
    echo ""
    echo "The questionnaire backend is working correctly!"
    echo ""
    echo "You can now:"
    echo "  1. Test via frontend: cd frontend && npm run dev"
    echo "  2. View in database: Query esg_questionnaires table"
    echo "  3. Check vendor progress updated in vendors table"
else
    echo -e "${RED}Status: FAILED ✗${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check Lambda logs:"
    echo "     aws logs tail /aws/lambda/OnboardingHubLambdaStack-QuestionnaireHandler --follow"
    echo "  2. Verify database connection"
    echo "  3. Check API Gateway configuration"
fi

echo ""
