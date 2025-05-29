import json
import traceback
from datetime import datetime, date
from models.contact import Contact
from services.dynamodb_service import save_contact

def lambda_handler(event, context):
    if event["httpMethod"] != "POST":
        return {"statusCode": 405, "body": "Method Not Allowed"}


    try:
        data = json.loads(event["body"])

        # Enforce required fields
        if not data.get("name") or not data.get("email"):
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Both 'name' and 'email' are required."})
            }

        contact = Contact(
            name=data.get("name"), 
            email=data.get("email"),
            phone=data.get("phone"),
            position_applied=data.get("position_applied"),
            company=data.get("company"),
            recruiter_company=data.get("recruiter_company"),
            last_contacted=parse_optional_datetime(data.get("last_contacted")),
            next_follow_up=parse_optional_date(data.get("next_follow_up")),
            notes=data.get("notes"),
            status=data.get("status")
        )

        

            
        save_contact(contact)

        return {
            "statusCode": 201,
            "body": json.dumps(contact.to_dict())
        }

    except Exception as e:
        print("Lambda error:", str(e))
        traceback.print_exc()
        return {
            "statusCode": 500,
            "body": f"Internal error: {str(e)}"
        }
        
def parse_optional_datetime(value):
    if value:
        try:
            return datetime.fromisoformat(value)
        except Exception:
            pass
    return None

def parse_optional_date(value):
    if value:
        try:
            return date.fromisoformat(value)
        except Exception:
            pass
    return None