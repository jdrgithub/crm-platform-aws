import os
from dotenv import load_dotenv

# Explicitly load the .env from project root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../../.env'))

import requests
import pytest

@pytest.mark.skipif(
    not os.getenv("API_GATEWAY_URL"),
    reason="API_GATEWAY_URL not set"
)
def test_post_contacts():
    url = os.getenv("API_GATEWAY_URL")
    assert url is not None
    
    payload = {
        "name": "Alice",
        "email": "alice@example.com"
    }
    
    response = requests.post(url, json=payload})
    assert response.status_code == 200
    assert "Hello from CRM Lambda" in response.text
