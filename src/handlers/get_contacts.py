import boto3
import json
import os
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE", "Contacts")
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        response = table.scan()
        contacts = response.get("Items", [])

        return {
            "statusCode": 200,
            "body": json.dumps(contacts),
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
                "Access-Control-Allow-Headers": "*"
            }
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }