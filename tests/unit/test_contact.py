# tests/unit/test_contact.py

from models.contact import Contact
from datetime import datetime, date, timezone
import uuid

def test_contact_to_dict_full():
    contact_id = str(uuid.uuid4())
    name = "Alice Example"
    email = "alice@example.com"
    phone = "123-456-7890"
    created_at = datetime(2024, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
    position_applied = "DevOps Engineer"
    recruiter_company = "Amazon"
    last_contacted = datetime(2024, 12, 1, 10, 30, 0, tzinfo=timezone.utc)
    next_follow_up = date(2024, 12, 10)
    notes = "Follow up in 1 week"
    status = "Awaiting feedback"

    contact = Contact(
        contact_id=contact_id,
        name=name,
        email=email,
        phone=phone,
        created_at=created_at,
        position_applied=position_applied,
        recruiter_company=recruiter_company,
        last_contacted=last_contacted,
        next_follow_up=next_follow_up,
        notes=notes,
        status=status
    )

    result = contact.to_dict()

    assert result["contact_id"] == contact_id
    assert result["name"] == name
    assert result["email"] == email
    assert result["phone"] == phone
    assert result["created_at"] == created_at.isoformat()
    assert result["position_applied"] == position_applied
    assert result["recruiter_company"] == recruiter_company
    assert result["last_contacted"] == last_contacted.isoformat()
    assert result["next_follow_up"] == next_follow_up.isoformat()
    assert result["notes"] == notes
    assert result["status"] == status

def test_contact_to_dict_minimal():
    # Test with only required fields
    name = "Bob Smith"
    email = "bob@example.com"
    contact = Contact(name=name, email=email)

    result = contact.to_dict()

    assert result["name"] == name
    assert result["email"] == email
    assert result["contact_id"] is not None
    assert result["created_at"] is not None
    assert "phone" in result
    assert "position_applied" in result
    assert "recruiter_company" in result
    assert "last_contacted" in result
    assert "next_follow_up" in result
    assert "notes" in result
    assert "status" in result
