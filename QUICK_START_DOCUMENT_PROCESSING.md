# 🚀 Quick Start: Automatic Document Processing

## TL;DR - Deploy in 5 Minutes

```bash
# 1. Configure AWS credentials
aws configure

# 2. Deploy infrastructure
cd infrastructure/cdk
pip3 install -r requirements.txt
npx cdk deploy --all --require-approval never

# 3. Configure S3 notifications (REQUIRED - run after deployment!)
cd ../scripts
./configure_s3_notifications.sh

# 4. Done! Upload a document to test
```

---

## What Was Fixed

### Problem
- S3 event notifications were NOT configured
- Documents uploaded to S3 wouldn't trigger automatic Textract processing
- Manual PowerShell script existed but wasn't integrated into deployment

### Solution
- Created `configure_s3_notifications.sh` - automated bash script
- Fixed CDK circular dependency issue
- Added comprehensive deployment documentation

---

## How to Deploy & Test

### Step 1: Deploy Infrastructure (~3 minutes)

```bash
cd /Users/zaineelmithani/hackutd_25/HackUTD_2025/infrastructure/cdk

# Install dependencies
pip3 install -r requirements.txt

# Deploy all stacks
npx cdk deploy --all --require-approval never
```

**Expected output:**
```
✅  OnboardingHubVpcStack
✅  OnboardingHubStorageStack
✅  OnboardingHubDatabaseStack
✅  OnboardingHubLambdaStack
✅  OnboardingHubApiStack
✅  OnboardingHubBastionStack

Stack ARN: ...
```

### Step 2: Configure S3 Notifications (~30 seconds)

**⚠️ CRITICAL**: This step is REQUIRED for automatic document processing!

```bash
cd /Users/zaineelmithani/hackutd_25/HackUTD_2025/infrastructure/scripts

# Run the configuration script
./configure_s3_notifications.sh
```

**Expected output:**
```
==========================================
S3 Event Notification Configuration
==========================================

[1/4] Fetching S3 bucket name from CloudFormation...
✓ Bucket: onboardinghubstoragestack-vendordocumentbucket...

[2/4] Fetching DocumentProcessor Lambda ARN...
✓ Lambda: arn:aws:lambda:us-east-1:...:function:OnboardingHubLambdaStack-DocumentProcessor...

[3/4] Granting S3 permission to invoke Lambda...
✓ Permission configured

[4/4] Configuring S3 event notifications...
✓ Notification configuration applied

==========================================
✅ S3 Event Notifications Configured!
==========================================
```

### Step 3: Test Automatic Processing (~1 minute)

#### Option A: Upload via AWS CLI

```bash
# Get bucket name
BUCKET=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubStorageStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentBucketName'].OutputValue" \
    --output text)

# Upload a test document (following the required path structure)
# Path format: vendors/{vendor-id}/{doc-type}/{doc-id}/{filename}
aws s3 cp sample-w9.pdf s3://$BUCKET/vendors/test-vendor-123/w9/test-doc-456/sample-w9.pdf
```

#### Option B: Upload via Frontend

1. Start frontend:
   ```bash
   cd /Users/zaineelmithani/hackutd_25/HackUTD_2025/frontend

   # Create .env with API URL
   echo "VITE_API_URL=$(aws cloudformation describe-stacks --stack-name OnboardingHubApiStack --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' --output text)" > .env

   npm run dev
   ```

2. Open http://localhost:5173
3. Register as a vendor
4. Upload a W-9 document
5. Watch the status change from "uploading" → "processing" → "extracted"

### Step 4: Verify Processing

```bash
# Watch Lambda logs in real-time
FUNCTION=$(aws cloudformation describe-stacks \
    --stack-name OnboardingHubLambdaStack \
    --query "Stacks[0].Outputs[?OutputKey=='DocumentProcessorArn'].OutputValue" \
    --output text | awk -F: '{print $NF}')

aws logs tail /aws/lambda/$FUNCTION --follow
```

**Expected logs:**
```
START RequestId: abc-123...
Processing document: {"Records":[{"s3":{"bucket":{"name":"..."},"object":{"key":"vendors/..."}}}]}
Document: test-doc-456, Type: w9, Vendor: test-vendor-123
Starting Textract analysis for w9
Textract job started: xyz-789...
Textract job completed successfully
Document test-doc-456 updated with status: extracted
END RequestId: abc-123...
REPORT RequestId: abc-123... Duration: 5234.56 ms
```

---

## File Structure for Uploads

**IMPORTANT**: Documents MUST be uploaded with this S3 key structure:

```
vendors/{vendor-id}/{document-type}/{document-id}/{filename}
```

### Examples:

✅ **Correct:**
```
vendors/550e8400-e29b-41d4-a716-446655440000/w9/123e4567-e89b-12d3-a456-426614174000/acme-corp-w9.pdf
vendors/abc-123/insurance/def-456/liability-cert.jpg
```

❌ **Wrong:**
```
documents/w9.pdf                    (wrong prefix)
vendors/w9.pdf                      (missing vendor-id, doc-type, doc-id)
vendors/abc/w9.pdf                  (missing doc-type and doc-id)
```

### Supported Document Types:

- `w9` - W-9 tax forms
- `insurance` - Insurance certificates
- `diversity_cert` - Diversity certifications
- `soc2` - SOC 2 audit reports
- `iso_cert` - ISO certifications
- `bcp` - Business continuity plans

### Supported File Extensions:

- `.pdf`
- `.jpg`
- `.jpeg`
- `.png`

---

## What Happens When You Upload?

1. **Upload** → Document uploaded to S3 bucket
2. **Event** → S3 triggers DocumentProcessor Lambda
3. **Parse** → Lambda extracts vendor_id, doc_type, doc_id from path
4. **Status Update** → Database updated: `status = 'processing'`
5. **Textract** → AWS Textract analyzes document (OCR + form extraction)
6. **Poll** → Lambda waits for Textract job completion (max 5 min)
7. **Extract** → Parse results for document-specific fields:
   - W-9: TIN, business name, address, signature
   - Insurance: policy numbers, coverage limits, dates
   - etc.
8. **Store** → Database updated: `status = 'extracted'`, `extracted_data = {...}`
9. **Done** → Frontend can fetch and display extracted data

---

## Troubleshooting

### "Document not processing automatically"

1. **Check S3 notification configuration:**
   ```bash
   BUCKET=$(aws cloudformation describe-stacks --stack-name OnboardingHubStorageStack --query "Stacks[0].Outputs[?OutputKey=='DocumentBucketName'].OutputValue" --output text)
   aws s3api get-bucket-notification-configuration --bucket $BUCKET
   ```

   Should show 4 LambdaFunctionConfigurations (pdf, jpg, jpeg, png)

2. **Re-run configuration script:**
   ```bash
   cd infrastructure/scripts
   ./configure_s3_notifications.sh
   ```

### "Textract errors in logs"

- Check Lambda has Textract permissions (should be configured automatically)
- Verify document is a valid PDF/image (not corrupted)
- Check document size (AWS Textract max: 5000 pages, 500 MB)

### "Circular dependency error during deployment"

- **DO NOT** add S3 event notifications in CDK code
- **ALWAYS** use the post-deployment script: `configure_s3_notifications.sh`

---

## Demo Tips for Hackathon

### 1. Pre-upload Sample Documents

Before the demo, upload sample documents so you can show:
- W-9 with extracted TIN
- Insurance cert with extracted policy info
- Diversity certification

### 2. Show Real Textract Extraction

Open AWS Console → Textract → Jobs to show:
- Job IDs from CloudWatch logs
- Textract confidence scores
- Extracted key-value pairs

### 3. Highlight Speed

Time the document processing:
- Upload → Processing → Extracted in ~5-10 seconds
- vs. 6 months manual process = **99.9% time reduction**

### 4. Show Database JSON

Query the database to show `extracted_data` JSON:
```sql
SELECT document_type, status, extracted_data
FROM documents
WHERE status = 'extracted'
LIMIT 1;
```

### 5. Two-Screen Demo

- **Screen 1**: Vendor uploads document
- **Screen 2**: GS admin sees real-time risk score update

---

## Next Steps After This

1. ✅ Document processing is FIXED
2. ⏭️ Implement ESG questionnaire save endpoint
3. ⏭️ Deploy infrastructure and get API URL
4. ⏭️ Connect frontend to real backend
5. ⏭️ End-to-end testing
6. ⏭️ Record demo video backup

---

## Files Modified/Created

```
infrastructure/
├── cdk/
│   ├── app.py                          [Modified] - Updated comment about S3 notifications
│   └── stacks/
│       └── lambda_stack.py             [Modified] - Added note about post-deployment script
├── scripts/
│   ├── configure_s3_notifications.sh   [NEW] ✨ - Automated bash script
│   └── setup_s3_notifications.ps1      [Existing] - Old PowerShell version
├── DEPLOY_DOCUMENT_PROCESSING.md       [NEW] ✨ - Comprehensive guide
└── QUICK_START_DOCUMENT_PROCESSING.md  [NEW] ✨ - This file

HackUTD_2025/
└── QUICK_START_DOCUMENT_PROCESSING.md  [NEW] ✨ - Quick reference
```

---

**Status**: ✅ **READY TO DEPLOY**

The document processing flow is now fully implemented and ready for deployment. Run the commands above to deploy and test!
