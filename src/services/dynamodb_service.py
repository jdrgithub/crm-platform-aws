# pyright: reportAttributeAccessIssue=false
import boto3
import os

def save_contact(contact):
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ.get("DYNAMODB_TABLE", "Contacts")
    table = dynamodb.Table(table_name)
    table.put_item(Item=contact.to_dict())
