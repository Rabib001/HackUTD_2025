"""
Lambda Function: Questionnaire Handler
Saves vendor KY3P questionnaire responses to database
"""
import json
import boto3
import psycopg2
import os
from datetime import datetime
from decimal import Decimal

secrets_client = boto3.client('secretsmanager', region_name='us-east-1')

def get_db_connection():
    """Get database connection using Secrets Manager credentials"""
    secret_arn = os.environ['DB_SECRET_ARN']
    response = secrets_client.get_secret_value(SecretId=secret_arn)
    secret = json.loads(response['SecretString'])

    return psycopg2.connect(
        host=os.environ['DB_HOST'],
        port=os.environ['DB_PORT'],
        database=os.environ['DB_NAME'],
        user=secret['username'],
        password=secret['password']
    )

def transform_questionnaire_to_questions(form_data):
    """
    Transform frontend form data to database questions format

    Args:
        form_data: Dict with all questionnaire fields

    Returns:
        List of question/answer objects
    """
    questions = []

    # Define question mappings
    question_mappings = {
        # Company Information
        'business_description': {
            'section': 'Company Information',
            'question': 'Business Description',
            'required': True
        },
        'years_in_business': {
            'section': 'Company Information',
            'question': 'Years in Business',
            'required': True
        },
        'number_of_employees': {
            'section': 'Company Information',
            'question': 'Number of Employees',
            'required': True
        },
        'annual_revenue': {
            'section': 'Company Information',
            'question': 'Annual Revenue Range',
            'required': True
        },

        # Compliance & Legal
        'compliance_certifications': {
            'section': 'Compliance & Legal',
            'question': 'Compliance Certifications',
            'required': False
        },
        'data_privacy_compliance': {
            'section': 'Compliance & Legal',
            'question': 'Data Privacy Compliance',
            'required': True
        },
        'sanctions_screening': {
            'section': 'Compliance & Legal',
            'question': 'Sanctions Screening Process',
            'required': True
        },
        'litigation_history': {
            'section': 'Compliance & Legal',
            'question': 'Litigation History (past 5 years)',
            'required': False
        },

        # Cybersecurity
        'security_certifications': {
            'section': 'Cybersecurity',
            'question': 'Security Certifications',
            'required': False
        },
        'incident_response_plan': {
            'section': 'Cybersecurity',
            'question': 'Incident Response Plan',
            'required': True
        },
        'data_encryption': {
            'section': 'Cybersecurity',
            'question': 'Data Encryption Standards',
            'required': True
        },
        'access_controls': {
            'section': 'Cybersecurity',
            'question': 'Access Controls',
            'required': True
        },

        # Financial & Operations
        'financial_health': {
            'section': 'Financial & Operations',
            'question': 'Financial Health Assessment',
            'required': True
        },
        'insurance_coverage': {
            'section': 'Financial & Operations',
            'question': 'Insurance Coverage',
            'required': True
        },
        'backup_procedures': {
            'section': 'Financial & Operations',
            'question': 'Backup & Recovery Procedures',
            'required': True
        },

        # ESG & Sustainability
        'esg_policies': {
            'section': 'ESG & Sustainability',
            'question': 'ESG Policies',
            'required': False
        },
        'diversity_initiatives': {
            'section': 'ESG & Sustainability',
            'question': 'Diversity & Inclusion Initiatives',
            'required': False
        },
        'environmental_commitments': {
            'section': 'ESG & Sustainability',
            'question': 'Environmental Commitments',
            'required': False
        },
    }

    # Transform each field into a question object
    for field_name, mapping in question_mappings.items():
        answer = form_data.get(field_name, '')

        # Skip empty non-required fields
        if not answer and not mapping['required']:
            continue

        # Convert arrays to comma-separated strings
        if isinstance(answer, list):
            answer = ', '.join(answer) if answer else ''

        questions.append({
            'section': mapping['section'],
            'question': mapping['question'],
            'answer': str(answer),
            'required': mapping['required'],
            'answered': bool(answer)
        })

    return questions

def calculate_completion(questions):
    """Calculate questionnaire completion statistics"""
    total_questions = len(questions)
    answered_questions = sum(1 for q in questions if q.get('answered', False))
    completion_percentage = (answered_questions / total_questions * 100) if total_questions > 0 else 0

    return {
        'total_questions': total_questions,
        'answered_questions': answered_questions,
        'completion_percentage': round(completion_percentage, 2)
    }

def save_questionnaire(vendor_id, form_data):
    """Save questionnaire to database"""
    try:
        # Transform form data to questions format
        questions = transform_questionnaire_to_questions(form_data)

        # Calculate completion stats
        stats = calculate_completion(questions)

        # Connect to database
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if vendor exists
        cursor.execute("""
            SELECT id FROM vendors WHERE id = %s
        """, (vendor_id,))

        vendor = cursor.fetchone()
        if not vendor:
            cursor.close()
            conn.close()
            return {
                'success': False,
                'error': 'Vendor not found'
            }

        # Check if questionnaire already exists for this vendor
        cursor.execute("""
            SELECT id FROM esg_questionnaires WHERE vendor_id = %s
        """, (vendor_id,))

        existing = cursor.fetchone()

        if existing:
            # Update existing questionnaire
            cursor.execute("""
                UPDATE esg_questionnaires
                SET questions = %s::jsonb,
                    total_questions = %s,
                    answered_questions = %s,
                    completion_percentage = %s,
                    completed_at = NOW()
                WHERE vendor_id = %s
                RETURNING id
            """, (
                json.dumps(questions),
                stats['total_questions'],
                stats['answered_questions'],
                stats['completion_percentage'],
                vendor_id
            ))
        else:
            # Insert new questionnaire
            cursor.execute("""
                INSERT INTO esg_questionnaires (
                    vendor_id,
                    questions,
                    auto_filled,
                    total_questions,
                    answered_questions,
                    completion_percentage
                )
                VALUES (%s, %s::jsonb, %s, %s, %s, %s)
                RETURNING id
            """, (
                vendor_id,
                json.dumps(questions),
                False,  # Not auto-filled
                stats['total_questions'],
                stats['answered_questions'],
                stats['completion_percentage']
            ))

        questionnaire_id = cursor.fetchone()[0]

        # Update vendor progress if questionnaire is complete
        if stats['completion_percentage'] >= 90:
            # Update vendor status to indicate questionnaire is complete
            cursor.execute("""
                UPDATE vendors
                SET onboarding_progress = GREATEST(onboarding_progress, 75),
                    updated_at = NOW()
                WHERE id = %s
            """, (vendor_id,))

        # Create audit log
        cursor.execute("""
            INSERT INTO audit_logs (
                vendor_id,
                action,
                metadata,
                actor
            )
            VALUES (%s, %s, %s::jsonb, %s)
        """, (
            vendor_id,
            'questionnaire_submitted',
            json.dumps({
                'questionnaire_id': str(questionnaire_id),
                'total_questions': stats['total_questions'],
                'answered_questions': stats['answered_questions'],
                'completion_percentage': float(stats['completion_percentage'])
            }),
            'vendor'
        ))

        conn.commit()
        cursor.close()
        conn.close()

        print(f"Questionnaire saved successfully for vendor {vendor_id}")
        print(f"Stats: {stats}")

        return {
            'success': True,
            'questionnaire_id': str(questionnaire_id),
            'stats': stats
        }

    except Exception as e:
        print(f"Error saving questionnaire: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'success': False,
            'error': str(e)
        }

def get_questionnaire(vendor_id):
    """Get questionnaire for a vendor"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                id,
                questions,
                auto_filled,
                total_questions,
                answered_questions,
                completion_percentage,
                completed_at
            FROM esg_questionnaires
            WHERE vendor_id = %s
            ORDER BY completed_at DESC
            LIMIT 1
        """, (vendor_id,))

        result = cursor.fetchone()
        cursor.close()
        conn.close()

        if not result:
            return {
                'success': False,
                'error': 'Questionnaire not found'
            }

        return {
            'success': True,
            'questionnaire': {
                'id': str(result[0]),
                'questions': result[1],
                'auto_filled': result[2],
                'total_questions': result[3],
                'answered_questions': result[4],
                'completion_percentage': float(result[5]),
                'completed_at': result[6].isoformat() if result[6] else None
            }
        }

    except Exception as e:
        print(f"Error getting questionnaire: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'success': False,
            'error': str(e)
        }

def handler(event, context):
    """
    Lambda handler for questionnaire operations

    POST /vendors/{vendor_id}/questionnaire - Submit questionnaire
    GET /vendors/{vendor_id}/questionnaire - Get questionnaire

    Body (POST):
    {
        "business_description": "...",
        "years_in_business": 5,
        ...all questionnaire fields
    }
    """
    try:
        print(f"Questionnaire handler event: {json.dumps(event)}")

        # Get vendor_id from path parameters
        vendor_id = event.get('pathParameters', {}).get('vendor_id') or event.get('pathParameters', {}).get('id')

        if not vendor_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'vendor_id is required'
                })
            }

        # Handle different HTTP methods
        http_method = event.get('httpMethod', 'POST')

        if http_method == 'GET':
            # Get questionnaire
            result = get_questionnaire(vendor_id)

            if result['success']:
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps(result['questionnaire'])
                }
            else:
                return {
                    'statusCode': 404 if 'not found' in result.get('error', '').lower() else 500,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({
                        'error': result.get('error', 'Failed to get questionnaire')
                    })
                }

        elif http_method == 'POST':
            # Save questionnaire
            # Parse request
            if isinstance(event.get('body'), str):
                body = json.loads(event['body'])
            else:
                body = event.get('body', {})

            result = save_questionnaire(vendor_id, body)

            if result['success']:
                return {
                    'statusCode': 200,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({
                        'message': 'Questionnaire submitted successfully',
                        'questionnaire_id': result['questionnaire_id'],
                        'completion_percentage': result['stats']['completion_percentage'],
                        'answered_questions': result['stats']['answered_questions'],
                        'total_questions': result['stats']['total_questions']
                    })
                }
            else:
                return {
                    'statusCode': 400 if 'not found' in result.get('error', '').lower() else 500,
                    'headers': {
                        'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'
                    },
                    'body': json.dumps({
                        'error': result.get('error', 'Failed to save questionnaire')
                    })
                }

        else:
            return {
                'statusCode': 405,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': f'Method {http_method} not allowed'
                })
            }

    except Exception as e:
        print(f"Handler error: {str(e)}")
        import traceback
        traceback.print_exc()

        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
