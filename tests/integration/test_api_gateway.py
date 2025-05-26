import os
from dotenv import load_dotenv

load_dotenv()

import requests
import pytest

@pytest.mark.skipif(
    not os.getenv("API_GATEWAY_URL"),
    reason="API_GATEWAY_URL not set"
)
def test_post_contacts():
    url = os.getenv("API_GATEWAY_URL")
    response = requests.post(url)
    assert response.status_code == 200
    assert "Hello from CRM Lambda" in response.text
