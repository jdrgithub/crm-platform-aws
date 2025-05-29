import os
from dotenv import load_dotenv

# Explicitly load the .env from project root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../../.env'))

import requests
import pytest
from datetime import datetime

@pytest.mark.skipif(
    not os.getenv("API_GATEWAY_URL"),
    reason="API_GATEWAY_URL not set"
)
def test_post_contacts_full_payload():
    url = os.getenv("API_GATEWAY_URL")
    assert url is not None

    payload = {
        "name": "Alice",
        "email": "alice@example.com",
        "phone": "123-456-7890",
        "position_applied": "DevOps Engineer",
        "company": "WidgetCorp",
        "recruiter_company": "Amazon",
        "last_contacted": "2025-05-27T14:33:00",
        "next_follow_up": "2025-06-01",
        "notes": "Said to follow up in 1 week",
        "status": "Awaiting feedback"
    }

    response = requests.post(url, json=payload)
    assert response.status_code in [200, 201]

    data = response.json()
    for key in payload:
        assert key in data
        assert data[key] == payload[key]

    assert "contact_id" in data
    assert "created_at" in data
