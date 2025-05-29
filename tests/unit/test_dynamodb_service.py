import pytest
from unittest.mock import patch, MagicMock
from services.dynamodb_service import save_contact
from models.contact import Contact
from datetime import datetime

@patch("services.dynamodb_service.boto3.resource")
def test_save_contact(mock_boto_resource):
    # Setup -> sets up the mocks and contact instance
    
    # mocks dynamodb table 
    mock_table = MagicMock()

    # mocks the boto3.resource fucntion to avoid calling aws
    mock_boto_resource.return_value.Table.return_value = mock_table

    contact = Contact(
        contact_id="1234",
        name="Test User",
        email="test@example.com",
        phone="555-5555",
        created_at=datetime(2024, 1, 1, 12, 0, 0)
    )

    # Act -> executes the function with mocks
    save_contact(contact)

    # Assert -> asserts that these occurred 
    mock_boto_resource.assert_called_once_with("dynamodb")
    mock_table.put_item.assert_called_once_with(Item=contact.to_dict())
