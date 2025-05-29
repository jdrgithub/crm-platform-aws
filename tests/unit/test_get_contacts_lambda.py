import json
from unittest.mock import patch, MagicMock
from handlers.get_contacts import lambda_handler

def test_lambda_handler_success():
    mock_response = {"Items": [{"name": "Test User", "email": "test@example.com"}]}
    
    with patch("handlers.get_contacts.table") as mock_table:
        mock_table.scan.return_value = mock_response
        
        response = lambda_handler({}, None)
        body = json.loads(response["body"])

        assert response["statusCode"] == 200
        assert isinstance(body, list)
        assert body[0]["name"] == "Test User"
        assert "Access-Control-Allow-Origin" in response["headers"]

def test_lambda_handler_exception():
    with patch("handlers.get_contacts.table") as mock_table:
        mock_table.scan.side_effect = Exception("Scan failed")
        
        response = lambda_handler({}, None)
        body = json.loads(response["body"])

        assert response["statusCode"] == 500
        assert "error" in body
        assert "Scan failed" in body["error"]
