import os
import requests
import pytest
from dotenv import load_dotenv

@pytest.mark.skipif(not os.getenv("API_GATEWAY_URL"), reason="API_GATEWAY_URL not set")
def test_post_contacts():
    url = os.getenv("API_GATEWAY_URL") # lOAD FROM .env or Jenkins env
    response = requests.post(f"{url}")
    assert response.status_code == 200
    assert "Hello from CRM Lambda" in response.text