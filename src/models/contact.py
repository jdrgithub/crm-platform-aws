# src/models/contact.py 

from datetime import datetime, timezone
import uuid

class Contact:
    def __init__(
        self, 
        contact_id=None, 
        name=None, 
        email=None, 
        phone=None, 
        position_applied=None,
        company=None,
        recruiter_company=None,
        last_contacted=None,
        next_follow_up=None,
        notes=None,
        status=None,
        created_at=None
    ):
        """
        Initialization of new contact.

        Args:
            id (str):                   unique contact identifier
            name (str):                 contact name
            email (str):                email
            phone (str):                phone #
            position_applied (str):     job title applied for
            company (str):              company applying to
            recruiter_company (str):    company of the recruiter
            last_contacted (datetime):  last time interacted
            next_follow_up (date):      date to follow up
            notes (str):                freeform notes
            status (str):               status of contact (e.g. awaiting feedback)
            created_at (datetime):      creation timestamp
        """
        self.contact_id = contact_id or str(uuid.uuid4()) # fallback if missing
        self.name = name
        self.email = email
        self.phone = phone
        self.position_applied = position_applied
        self.company = company
        self.recruiter_company = recruiter_company
        self.last_contacted = last_contacted
        self.next_follow_up = next_follow_up
        self.notes = notes
        self.status = status
        self.created_at = created_at or datetime.now(timezone.utc) # use now if no arg provided

    def to_dict(self):
        """
        Converting the Contact object to a dictionary for later serialized with json.dumps.
        
        Returns ->  dict: A dictionary representation of the contact.
        """
        return {
            "contact_id": self.contact_id,
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "position_applied": self.position_applied,
            "company": self.company,
            "recruiter_company": self.recruiter_company,
            "last_contacted": self.last_contacted.isoformat() if self.last_contacted else None,
            "next_follow_up": self.next_follow_up.isoformat() if self.next_follow_up else None,
            "notes": self.notes,
            "status": self.status,
            "created_at": self.created_at.isoformat()  # because json dumps can't handle normal datetime.now output
        }

