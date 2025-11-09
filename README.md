# AutoBoard
The AWS-native platform that automates financial vendor onboarding, reducing compliance timelines from weeks to hours.

# Inspiration
At major financial institutions like Goldman Sachs, vendor onboarding is a critical compliance function bogged down by manual document review. Teams are drowning in paperwork, creating a costly bottleneck that can take weeks to resolve. We built AutoBoard to automate this entire lifecycle and give compliance teams their time back.

# What It Does
AutoBoard transforms the vendor lifecycle into a streamlined, automated workflow:

**AI-Powered Document Intake**: Instantly extracts and validates data from W-9s, insurance certificates, and other complex forms using AWS Textract.

**Automated Compliance**: Guides vendors through a smart, 18-field KY3P (Know Your 3rd Party) questionnaire with real-time validation.

**Multi-Dimensional Risk Scoring**: Automatically analyzes vendors across key risk vectors, including compliance, cybersecurity, financial health, and ESG.

**One-Click Workflows**: Empowers compliance teams to review, approve, and provision vendors with a single click, generating a complete, immutable audit trail.

**Real-Time Tracking Portal**: Provides both internal teams and external vendors with a live dashboard to track their onboarding status from registration to final approval.

# How We Built It

We engineered a robust, secure, and scalable system using a 100% AWS serverless architecture, fully defined and deployable via Infrastructure as Code.

Frontend: A responsive vendor portal built with React, Vite, and Tailwind CSS.
Backend (AWS Serverless):
Compute: 7 individual AWS Lambda functions (Python)
