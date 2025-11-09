# Frontend-Backend Integration Guide

Complete guide for connecting the React frontend to the AWS Lambda backend.

## Current Status

✅ **Frontend**: React app with mock data (fully functional offline)
✅ **Backend**: Lambda functions with correct API response formats
✅ **API Contract**: Frontend and backend are 100% aligned

## Quick Start

### Step 1: Deploy AWS Infrastructure

```bash
cd infrastructure/cdk

# Deploy all stacks in order
cdk deploy OnboardingHubVpcStack --require-approval never
cdk deploy OnboardingHubStorageStack --require-approval never
cdk deploy OnboardingHubDatabaseStack --require-approval never
cdk deploy OnboardingHubLambdaStack --require-approval never
cdk deploy OnboardingHubApiStack --require-approval never
cdk deploy OnboardingHubBastionStack --require-approval never

# Or deploy all at once
cdk deploy --all --require-approval never
```

**Important:** Save the API Gateway URL from the output:
```
✅  OnboardingHubApiStack

Outputs:
OnboardingHubApiStack.ApiUrl = https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/
```

### Step 2: Add psycopg2 Lambda Layer

**CRITICAL:** All Lambda functions need psycopg2 to connect to PostgreSQL.

See detailed instructions in `infrastructure/LAMBDA_LAYERS.md`

**Quick option** (use public layer):
1. Go to AWS Lambda Console
2. For each function (create_vendor, status_handler, risk_scoring, approve_vendor, db_init):
   - Click function → Scroll to "Layers"
   - Click "Add a layer" → "Specify an ARN"
   - Paste: `arn:aws:lambda:us-east-1:898466741470:layer:psycopg2-py311:1`
   - Click "Add"

### Step 3: Initialize Database

Using the bastion host (see `BASTION_SETUP.md`):

```bash
# Connect to bastion via AWS Console (Session Manager)
# Or via CLI:
aws ssm start-session --target <INSTANCE_ID> --region us-east-1

# On bastion:
cd /tmp
git clone https://github.com/Rabib001/HackUTD_2025.git
cd HackUTD_2025
python3 init_database.py
```

Expected output:
```
============================================================
[OK] Database initialization completed successfully!
============================================================
```

### Step 4: Configure Frontend for Production

Create `.env` file in `frontend/` directory:

```env
VITE_API_URL=https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod
```

Replace `abc123xyz` with your actual API Gateway ID from Step 1.

### Step 5: Run Frontend

```bash
cd frontend
npm install
npm run dev
```

Visit `http://localhost:5173` - Now connected to real backend!

### Step 6: Deploy Frontend (Optional)

#### Option A: Vercel (Recommended)
```bash
cd frontend
npm i -g vercel
vercel

# Add environment variable in Vercel dashboard:
# VITE_API_URL = https://your-api-gateway-url/prod
```

#### Option B: AWS S3 + CloudFront
```bash
cd frontend
VITE_API_URL=https://your-api-url npm run build

aws s3 mb s3://gs-vendor-frontend
aws s3 sync dist/ s3://gs-vendor-frontend
aws s3 website s3://gs-vendor-frontend \
  --index-document index.html \
  --error-document index.html
```

## API Endpoints Verified

All endpoints tested and aligned:

| Method | Endpoint | Frontend Usage | Status |
|--------|----------|----------------|--------|
| POST | `/vendors` | Create vendor account | ✅ Aligned |
| GET | `/vendors/{id}/status` | Dashboard page | ✅ Aligned |
| GET | `/vendors/{id}/risk-score` | Risk score page | ✅ Aligned |
| POST | `/vendors/{id}/risk-score` | Calculate new score | ✅ Aligned |
| POST | `/documents/upload` | Document upload | ✅ Aligned |
| POST | `/vendors/{id}/approve` | Admin approval | ✅ Aligned |

## Response Format Alignment

### ✅ POST /vendors (Create Vendor)

**Frontend Expects:**
```json
{
  "id": "uuid",
  "status": "submitted",
  "onboarding_progress": 0,
  "ky3p_assessment_id": "KY3P-ABC123",
  "slp_supplier_id": "SLP-ABC123",
  "created_at": "2025-11-09T..."
}
```

**Backend Returns:** ✅ Exact match

### ✅ GET /vendors/{id}/status

**Frontend Expects:**
```json
{
  "vendor_id": "uuid",
  "company_name": "ABC Corp",
  "status": "under_review",
  "onboarding_progress": 65,
  "ky3p_assessment_id": "KY3P-ABC123",
  "slp_supplier_id": "SLP-ABC123",
  "documents": [...],
  "next_steps": [...],
  "risk_score": 42,
  "timeline": [...]
}
```

**Backend Returns:** ✅ Exact match

### ✅ GET /vendors/{id}/risk-score

**Frontend Expects:**
```json
{
  "vendor_id": "uuid",
  "overall_score": 42,
  "financial_score": 30,
  "compliance_score": 45,
  "cybersecurity_score": 60,
  "esg_score": 25,
  "financial_findings": [...],
  "compliance_findings": [...],
  "cybersecurity_findings": [...],
  "esg_findings": [...],
  "recommendations": [...],
  "risk_level": "medium",
  "assessed_at": "2025-11-09T...",
  "next_review_date": "2026-02-09T..."
}
```

**Backend Returns:** ✅ Exact match

## Document Type Compatibility

The backend automatically normalizes document types:

| Frontend Sends | Backend Stores | Status |
|----------------|----------------|--------|
| `insurance_certificate` | `insurance` | ✅ Auto-converted |
| `business_license` | `business_license` | ✅ Direct match |
| `w9` | `w9` | ✅ Direct match |

## Testing the Integration

### 1. Test Vendor Creation

```bash
curl -X POST https://your-api-url/prod/vendors \
  -H "Content-Type: application/json" \
  -d '{
    "company_name": "Test Corp",
    "contact_email": "test@test.com",
    "ein": "12-3456789",
    "address": "123 Test St",
    "contact_phone": "+1-555-0100"
  }'
```

Expected: `201 Created` with vendor ID

### 2. Test Status Retrieval

```bash
curl https://your-api-url/prod/vendors/{vendor-id}/status
```

Expected: `200 OK` with vendor details, documents, timeline

### 3. Test Risk Score Calculation

```bash
curl -X POST https://your-api-url/prod/vendors/{vendor-id}/risk-score
```

Expected: `200 OK` with risk assessment details

### 4. Test Risk Score Retrieval

```bash
curl https://your-api-url/prod/vendors/{vendor-id}/risk-score
```

Expected: `200 OK` with existing risk score

## Mock vs. Real API

The frontend automatically switches modes:

**Mock Mode** (no .env file):
- Uses `frontend/src/services/mockData.js`
- Realistic fake data for demos
- No backend required
- Perfect for offline development

**Real API Mode** (.env with VITE_API_URL):
- Connects to AWS Lambda backend
- Real database storage
- AI-powered risk assessment
- Production-ready

## Troubleshooting

### Frontend shows "Failed to fetch"

**Solution:**
1. Check API Gateway URL in `.env`
2. Verify CORS is enabled (it is in api_stack.py)
3. Check browser console for detailed error

### Lambda returns "No module named 'psycopg2'"

**Solution:**
Add psycopg2 layer to all Lambda functions (see Step 2)

### Risk score always shows "not found"

**Solution:**
1. Upload documents first
2. Calculate risk score via POST endpoint
3. Then retrieve via GET endpoint

### Documents upload fails

**Solution:**
1. Check S3 bucket permissions
2. Verify KMS key access for Lambda
3. Check file size (max 10MB)

## CORS Configuration

CORS is already configured in API Gateway:

```python
# api_stack.py
default_cors_preflight_options=apigw.CorsOptions(
    allow_origins=apigw.Cors.ALL_ORIGINS,
    allow_methods=apigw.Cors.ALL_METHODS,
    allow_headers=["Content-Type", "Authorization", "X-Amz-Date"],
)
```

For production, update to specific origin:
```python
allow_origins=["https://your-frontend-domain.com"]
```

## Environment Variables Summary

### Frontend (.env)
```env
VITE_API_URL=https://abc123.execute-api.us-east-1.amazonaws.com/prod
```

### Backend (Lambda Environment - Auto-configured by CDK)
```env
DB_HOST=<rds-endpoint>
DB_PORT=5432
DB_NAME=onboarding_hub
DB_SECRET_ARN=arn:aws:secretsmanager:...
DOCUMENT_BUCKET=<s3-bucket-name>
```

## Security Checklist

Before going to production:

- [ ] Update CORS to specific domain (not ALL_ORIGINS)
- [ ] Enable API Gateway authentication (Cognito/API Keys)
- [ ] Rotate database credentials
- [ ] Enable CloudFront for frontend
- [ ] Enable S3 bucket encryption
- [ ] Review IAM permissions (least privilege)
- [ ] Enable CloudTrail logging
- [ ] Set up CloudWatch alarms

## Demo Flow

1. **Visit Homepage** - See value proposition
2. **Register** - Create vendor account (stores in RDS)
3. **Upload Documents** - W-9, Insurance, Business License (S3)
4. **View Dashboard** - See progress, status, timeline
5. **Check Risk Score** - AI-generated assessment with findings
6. **Track Progress** - Real-time updates via API

## Architecture Summary

```
React Frontend
    ↓ HTTPS
API Gateway (CORS enabled)
    ↓ Lambda Proxy
Lambda Functions (with psycopg2 layer)
    ↓ VPC
RDS PostgreSQL (private subnet)
    ↑ Session Manager
Bastion Host (t3.micro)

Documents stored in:
S3 Bucket (KMS encrypted)
```

## Success Metrics

Integration is successful when:

✅ Frontend loads without errors
✅ Can create vendor via form
✅ Documents upload to S3
✅ Risk score calculates correctly
✅ Dashboard shows real-time data
✅ All API responses match frontend expectations

## Need Help?

- **Backend Issues**: Check `infrastructure/LAMBDA_LAYERS.md`
- **Database Access**: See `BASTION_SETUP.md`
- **Frontend Setup**: Read `frontend/README.md`
- **API Spec**: See `infrastructure/docs/ARCHITECTURE.md`

---

**Ready to integrate!** Follow steps 1-5 above to connect your frontend to the backend. 🚀
