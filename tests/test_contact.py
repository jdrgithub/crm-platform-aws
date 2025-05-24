# tests/unit/test_contact.py

from models.contact import Contact
from datetime import datetime
import uuid

def test_contact_to_dict():
    contact_id = str(uuid.uuid4())
    name = "Alice Example"
    email = "alice@example.com"
    phone = "123-456-7890"
    created_at = datetime(2024, 1, 1, 12, 0, 0)

    contact = Contact(
        id=contact_id,
        name=name,
        email=email,
        phone=phone,
        created_at=created_at
    )

    result = contact.to_dict()

    assert result["id"] == contact_id
    assert result["name"] == name
    assert result["email"] == email
    assert result["phone"] == phone
    assert result["created_at"] == created_at.isoformat()
