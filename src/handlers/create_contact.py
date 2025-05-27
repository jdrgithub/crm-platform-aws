import json
from models.contact import Contact
from services.dynamodb_service import save_contact

def lambda_handler(event, context):
    if event["httpMethod"] != "POST":
        return {"statusCode": 405, "body": "Method Not Allowed"}

    try:
        data = json.loads(event["body"])
        contact = Contact(name=data["name"], email=data["email"])
        save_contact(contact)
        return {
            "statusCode": 201,
            "body": json.dumps(contact.to_dict())
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Internal error: {str(e)}"
        }