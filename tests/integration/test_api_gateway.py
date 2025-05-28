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
    
    response = requests.post(url, json=payload)
    assert response.status_code in [200, 201]

    data = response.json()
    assert data["name"] == "Alice"
    assert data["email"] == "alice@example.com"
    assert "contact_id" in data
    assert "created_at" in data