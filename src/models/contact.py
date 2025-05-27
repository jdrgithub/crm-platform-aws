# src/models/contact.py 

from datetime import datetime, timezone

class Contact:
    def __init__(self, id=None, name=None, email=None, phone=None, created_at=None):
        """
        Initialization of new contact.

        Args:
            id (str): unique contact identifier
            name (str): contact name
            email (str): email
            phone (str): phone #
            created_at (datetime, optional): creation timestamp
        """
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.created_at = created_at or datetime.now(timezone.utc) # use now if no arg provided

    def to_dict(self):
        """
        Converting the Contact object to a dictionary for later serialized with json.dumps.
        
        Returns ->  dict: A dictionary representation of the contact.
        """
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "created_at": self.created_at.isoformat()  # because json dumps can't handle normal datetime.now output
        }

