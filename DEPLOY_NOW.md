# 🚀 DEPLOY NOW - 3 Commands to Win the Hackathon

## ⚡ Ultra Quick Start (5 Minutes Total)

```bash
# 1. Update AWS credentials (if needed)
./update-aws-credentials.sh

# 2. Deploy everything
./deploy.sh

# 3. Test it works
./test-document-upload.sh
```

**That's it!** Your Goldman Sachs Vendor Onboarding Hub is live with automatic AI-powered document processing.

---

## 📋 What Gets Deployed

When you run `./deploy.sh`, it automatically:

1. ✅ **Installs dependencies** - Python packages, CDK
2. ✅ **Deploys AWS infrastructure** - VPC, S3, RDS, Lambda, API Gateway
3. ✅ **Configures S3 notifications** - Auto-triggers document processing
4. ✅ **Initializes database** - Creates schema + seed data
5. ✅ **Sets up frontend** - Creates .env with API URL

**Total Time:** 10-15 minutes (mostly waiting for AWS)

---

## 🔑 Step 1: AWS Credentials

### Check if you need to update credentials:

```bash
aws sts get-caller-identity
```

**If you see an error**, run:

```bash
./update-aws-credentials.sh
```

**Or manually:**

```bash
aws configure
```

You'll need:
- AWS Access Key ID
- AWS Secret Access Key
- Region: `us-east-1`
- Output: `json`

> **💡 Tip:** Check with your team member who deployed before - they may have credentials!

---

## 🚀 Step 2: Deploy

```bash
./deploy.sh
```

This single command does **everything**:

```
✓ Pre-flight checks (AWS CLI, Node, Python)
✓ Install Python dependencies
✓ Bootstrap CDK (first time only)
✓ Deploy 6 CloudFormation stacks:
  • OnboardingHubVpcStack
  • OnboardingHubStorageStack
  • OnboardingHubDatabaseStack
  • OnboardingHubLambdaStack
  • OnboardingHubApiStack
  • OnboardingHubBastionStack
✓ Configure S3 event notifications
✓ Initialize database schema
✓ Create frontend .env file
✓ Install frontend dependencies
✓ Save deployment info
```

**Expected output at the end:**

```
==========================================
✅ DEPLOYMENT COMPLETE!
==========================================

📋 Deployment Summary:

  🗄️  S3 Bucket:        onboardinghubstoragestack-vendordocumentbucket...
  🚀 API Gateway:      https://abc123.execute-api.us-east-1.amazonaws.com/prod/
  🤖 Document Processor: DocumentProcessor3D49A083-xyz
  💾 Database:         onboardinghubdatabasestack-vendordatabase...

🎯 Next Steps:
  1. Start the frontend: cd frontend && npm run dev
  2. Open browser to http://localhost:5173
  3. Test document upload!
```

---

## 🧪 Step 3: Test

### Option A: Automated Test

```bash
./test-document-upload.sh
```

This will:
1. Create a sample W-9 document
2. Upload to S3 with proper path structure
3. Show Lambda logs of Textract processing
4. Confirm extraction worked

### Option B: Manual Frontend Test

```bash
cd frontend
npm run dev
```

Then:
1. Open http://localhost:5173
2. Click "I'm a Vendor"
3. Register with test company info
4. Upload a W-9 PDF
5. Watch status change: uploading → processing → extracted
6. View extracted data (TIN, business name, etc.)

---

## 🎬 Demo Preparation

### Before Judging:

1. **Pre-load test vendors:**
   ```bash
   # Database already has 5 sample vendors from seed data!
   ```

2. **Upload sample documents:**
   ```bash
   ./test-document-upload.sh
   ```

3. **Start frontend:**
   ```bash
   cd frontend && npm run dev
   ```

4. **Open two browser windows:**
   - Window 1: Vendor view (http://localhost:5173)
   - Window 2: GS admin view (http://localhost:5173/gs/login)

### During Demo:

**Show the flow:**
1. **Vendor uploads W-9** → Show drag-and-drop UI
2. **AWS Textract extracts data** → Show CloudWatch logs with job ID
3. **Risk score auto-calculates** → Show the 4 dimensions (Financial, Compliance, Cyber, ESG)
4. **GS approves vendor** → Show approval workflow
5. **2 weeks vs 6 months** → Highlight the time savings

**Key talking points:**
- "Real AWS Textract integration, not mocked!"
- "Extracts TIN, policy numbers, dates automatically"
- "Replaces KY3P and Ariba with one unified platform"
- "Customer-managed KMS encryption for Goldman Sachs compliance"
- "85% time reduction: 180 days → 14 days"

---

## 🛠️ Troubleshooting

### Deploy script fails with "AWS credentials invalid"

```bash
./update-aws-credentials.sh
```

### "Command not found: cdk"

The script uses `npx cdk` (no install needed). But if it fails:

```bash
npm install -g aws-cdk
```

### "Module not found: aws_cdk"

```bash
cd infrastructure/cdk
pip3 install -r requirements.txt
```

### S3 notifications not triggering

```bash
cd infrastructure/scripts
./configure_s3_notifications.sh
```

### Database connection fails

Check security groups allow Lambda → RDS:

```bash
aws ec2 describe-security-groups --filters "Name=group-name,Values=*Database*"
```

### Frontend shows "API Error"

Check `.env` file exists:

```bash
cat frontend/.env
# Should show: VITE_API_URL=https://...
```

---

## 📊 Cost Breakdown

**For hackathon demo (~50 test documents):**

| Service | Usage | Cost |
|---------|-------|------|
| AWS Textract | 50 pages @ $1.50/1000 | $0.08 |
| Lambda | 100 invocations | $0.00 (free tier) |
| RDS Aurora | 2 hours serverless | $0.20 |
| S3 Storage | 1 GB | $0.02 |
| API Gateway | 100 requests | $0.00 (free tier) |
| **TOTAL** | | **~$0.30** |

> 💰 Essentially **free** for demo purposes!

---

## 📁 What Was Created

```
HackUTD_2025/
├── deploy.sh ✨                         # ONE-COMMAND DEPLOYMENT
├── update-aws-credentials.sh ✨         # Fix AWS credentials
├── test-document-upload.sh ✨           # Test Textract processing
├── DEPLOY_NOW.md ✨                     # This file
├── QUICK_START_DOCUMENT_PROCESSING.md ✨ # Detailed guide
├── DEPLOYMENT_INFO.txt                  # Auto-generated after deploy
│
├── infrastructure/
│   ├── scripts/
│   │   └── configure_s3_notifications.sh ✨  # S3 event config
│   ├── DEPLOY_DOCUMENT_PROCESSING.md ✨      # Comprehensive guide
│   └── cdk/
│       ├── app.py                       # CDK app entry point
│       └── stacks/                      # All CloudFormation stacks
│
├── frontend/
│   └── .env                             # Auto-generated with API URL
│
└── test-documents/
    └── sample-w9.pdf                    # Auto-generated test file
```

---

## ✅ Deployment Checklist

After running `./deploy.sh`, verify:

- [ ] All 6 CloudFormation stacks show `CREATE_COMPLETE`
- [ ] `DEPLOYMENT_INFO.txt` exists with bucket name and API URL
- [ ] `frontend/.env` contains `VITE_API_URL`
- [ ] S3 bucket has event notifications configured
- [ ] Database has schema and 5 seed vendors
- [ ] Test upload triggers Lambda execution
- [ ] Frontend connects to API successfully

---

## 🎯 Success Criteria

**You're ready for demo when:**

1. ✅ Frontend loads at http://localhost:5173
2. ✅ You can register a vendor
3. ✅ Document upload changes status to "processing" then "extracted"
4. ✅ Extracted data appears (TIN, business name, etc.)
5. ✅ GS dashboard shows vendors with risk scores
6. ✅ Approval workflow changes vendor status
7. ✅ CloudWatch logs show Textract job IDs

---

## 🏆 Demo Script

**Opening (30 seconds):**
> "Goldman Sachs takes 6 months to onboard a vendor using manual processes across KY3P and Ariba. We built an AI-powered platform that does it in 2 weeks."

**Demo (2 minutes):**
1. Show vendor registration
2. Upload W-9 → Show Textract extraction in real-time
3. Switch to GS view → Show risk score calculation
4. Approve vendor → Show status change

**Impact (30 seconds):**
> "We reduced onboarding from 180 days to 14 days - an 85% time reduction. Real AWS Textract integration extracts TIN, policy numbers, and dates automatically. Customer-managed KMS encryption meets Goldman's compliance requirements."

**Q&A (1 minute):**
- **Tech Stack:** AWS CDK, Lambda, Textract, Aurora PostgreSQL, React
- **Scalability:** Serverless architecture scales automatically
- **Security:** VPC isolation, KMS encryption, Secrets Manager
- **Cost:** ~$0.30 for demo, scales linearly with usage

---

## 📞 Need Help?

1. **Check logs:**
   ```bash
   aws logs tail /aws/lambda/OnboardingHubLambdaStack-DocumentProcessor --follow
   ```

2. **Verify deployment:**
   ```bash
   aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE
   ```

3. **Re-run specific steps:**
   ```bash
   # Just S3 notifications
   cd infrastructure/scripts && ./configure_s3_notifications.sh

   # Just frontend
   cd frontend && echo "VITE_API_URL=..." > .env && npm run dev
   ```

4. **Complete re-deploy:**
   ```bash
   ./deploy.sh
   ```

---

## 🎉 You're Ready!

Run these 3 commands and you're **demo-ready**:

```bash
./update-aws-credentials.sh  # If needed
./deploy.sh                  # Deploy everything
./test-document-upload.sh    # Verify it works
```

**Good luck at the hackathon! 🏆**

---

**Last updated:** November 9, 2025
**Deployment time:** ~15 minutes
**Demo-ready time:** ~20 minutes total
