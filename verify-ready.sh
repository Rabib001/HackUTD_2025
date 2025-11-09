#!/bin/bash
# Quick verification that everything is ready for deployment

echo "🔍 Checking deployment readiness..."
echo ""

READY=true

# Check scripts exist and are executable
echo "📋 Deployment Scripts:"
for script in deploy.sh update-aws-credentials.sh test-document-upload.sh; do
    if [ -x "$script" ]; then
        echo "  ✅ $script"
    else
        echo "  ❌ $script (missing or not executable)"
        READY=false
    fi
done
echo ""

# Check documentation exists
echo "📚 Documentation:"
for doc in START_HERE.txt README_DEPLOY.md DEPLOY_NOW.md; do
    if [ -f "$doc" ]; then
        echo "  ✅ $doc"
    else
        echo "  ❌ $doc (missing)"
        READY=false
    fi
done
echo ""

# Check infrastructure scripts
echo "🛠️  Infrastructure Scripts:"
if [ -x "infrastructure/scripts/configure_s3_notifications.sh" ]; then
    echo "  ✅ configure_s3_notifications.sh"
else
    echo "  ❌ configure_s3_notifications.sh (missing or not executable)"
    READY=false
fi
echo ""

# Check AWS credentials
echo "🔑 AWS Credentials:"
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    echo "  ✅ Valid credentials (Account: $ACCOUNT)"
else
    echo "  ⚠️  Invalid or expired - run ./update-aws-credentials.sh"
fi
echo ""

# Final verdict
echo "═══════════════════════════════════════"
if [ "$READY" = true ]; then
    echo "✅ READY FOR DEPLOYMENT!"
    echo ""
    echo "Run: ./deploy.sh"
else
    echo "❌ NOT READY - Fix issues above"
fi
echo "═══════════════════════════════════════"

