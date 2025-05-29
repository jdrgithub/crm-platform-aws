import json
from unittest.mock import patch
from handlers.create_contact import lambda_handler

def test_lambda_handler_success():
    event = {
        "httpMethod": "POST",
        "body": json.dumps({
            "name": "Charlie Brown",
            "email": "charlie@example.com",
            "phone": "555-1234",
            "position_applied": "Platform Engineer",
            "company": "Peanuts Inc",
            "recruiter_company": "Acme Recruiting",
            "last_contacted": "2024-12-01T10:30:00",
            "next_follow_up": "2024-12-10",
            "notes": "Good cultural fit",
            "status": "Submitted"
        })
    }

    # Mocking save_contact with mock save
    with patch("handlers.create_contact.save_contact") as mock_save:
        response = lambda_handler(event, None)
        body = json.loads(response["body"])

        assert response["statusCode"] == 201
        assert body["name"] == "Charlie Brown"
        assert body["email"] == "charlie@example.com"
        assert "contact_id" in body
        assert "created_at" in body
        mock_save.assert_called_once()

# These fail before they hit save_contact and write to db
def test_lambda_handler_invalid_method():
    event = {"httpMethod": "GET", "body": ""}
    response = lambda_handler(event, None)
    assert response["statusCode"] == 405
    assert response["body"] == "Method Not Allowed"

def test_lambda_handler_bad_json():
    event = {"httpMethod": "POST", "body": "{not:valid}"}
    response = lambda_handler(event, None)
    assert response["statusCode"] == 500
    assert "Internal error" in response["body"]
