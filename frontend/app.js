// ===== app.js =====

// API Gateway endpoint
const endpoint = "https://mn3vl1gj67.execute-api.us-east-1.amazonaws.com/dev/contacts";

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("contact-form");
  const contactIdField = document.getElementById("contact-id");

  // Form submission handler for create and update
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const formData = new FormData(form);
    const contactId = formData.get("contact_id");

    const contact = {
      name: formData.get("name"),
      email: formData.get("email"),
      phone: formData.get("phone"),
      position_applied: formData.get("position_applied"),
      recruiter_company: formData.get("recruiter_company"),
      last_contacted: formData.get("last_contacted"),
      next_follow_up: formData.get("next_follow_up"),
      status: formData.get("status"),
      notes: formData.get("notes")
    };

    try {
      const response = await fetch(
        contactId ? `${endpoint}/${contactId}` : endpoint,
        {
          method: contactId ? "PUT" : "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(contact)
        }
      );

      if (!response.ok) {
        throw new Error(`Failed to ${contactId ? "update" : "add"} contact: ${response.statusText}`);
      }

      const resultContact = await response.json();

      if (contactId) {
        updateTableRow(resultContact);
      } else {
        addContactToTable(resultContact);
      }

      form.reset();
      contactIdField.value = "";
    } catch (err) {
      console.error("Error submitting contact:", err);
      alert("Failed to submit contact. See console for details.");
    }
  });

  fetchContacts();
});

// Fetch contacts and display them in the table
async function fetchContacts() {
  try {
    const response = await fetch(endpoint);
    const data = await response.json();
    data.forEach(addContactToTable);
  } catch (err) {
    console.error("Error fetching contacts:", err);
    document.body.innerHTML += `<p style="color:red">Failed to load contacts</p>`;
  }
}

// Create and append a new row in the contacts table
function addContactToTable(contact) {
  const tbody = document.getElementById("contacts-body");
  const row = document.createElement("tr");
  row.setAttribute("data-id", contact.contact_id);

  row.innerHTML = `
    <td>${contact.name || ""}</td>
    <td>${contact.email || ""}</td>
    <td>${contact.phone || ""}</td>
    <td>${contact.position_applied || ""}</td>
    <td>${contact.recruiter_company || ""}</td>
    <td>${contact.last_contacted || ""}</td>
    <td>${contact.next_follow_up || ""}</td>
    <td>${contact.status || ""}</td>
    <td>${contact.notes || ""}</td>
    <td>${contact.created_at || ""}</td>
    <td>
      <button onclick="editContact('${contact.contact_id}')">Edit</button>
      <button onclick="deleteContact('${contact.contact_id}')">Delete</button>
    </td>
  `;
  tbody.appendChild(row);
}

// Populate form for editing a contact
function editContact(contactId) {
  const row = document.querySelector(`tr[data-id='${contactId}']`);
  if (!row) return;

  const cells = row.querySelectorAll("td");
  document.getElementById("contact-id").value = contactId;
  document.querySelector("[name='name']").value = cells[0].textContent;
  document.querySelector("[name='email']").value = cells[1].textContent;
  document.querySelector("[name='phone']").value = cells[2].textContent;
  document.querySelector("[name='position_applied']").value = cells[3].textContent;
  document.querySelector("[name='recruiter_company']").value = cells[4].textContent;
  document.querySelector("[name='last_contacted']").value = cells[5].textContent;
  document.querySelector("[name='next_follow_up']").value = cells[6].textContent;
  document.querySelector("[name='status']").value = cells[7].textContent;
  document.querySelector("[name='notes']").value = cells[8].textContent;
}

// Replace existing table row with updated contact info
function updateTableRow(contact) {
  const row = document.querySelector(`tr[data-id='${contact.contact_id}']`);
  if (!row) return;

  row.innerHTML = `
    <td>${contact.name || ""}</td>
    <td>${contact.email || ""}</td>
    <td>${contact.phone || ""}</td>
    <td>${contact.position_applied || ""}</td>
    <td>${contact.recruiter_company || ""}</td>
    <td>${contact.last_contacted || ""}</td>
    <td>${contact.next_follow_up || ""}</td>
    <td>${contact.status || ""}</td>
    <td>${contact.notes || ""}</td>
    <td>${contact.created_at || ""}</td>
    <td>
      <button onclick="editContact('${contact.contact_id}')">Edit</button>
      <button onclick="deleteContact('${contact.contact_id}')">Delete</button>
    </td>
  `;
}

// Delete a contact by ID and remove from the table
async function deleteContact(contactId) {
  if (!confirm("Are you sure you want to delete this contact?")) return;

  try {
    const response = await fetch(`${endpoint}/${contactId}`, {
      method: "DELETE"
    });

    if (!response.ok) {
      throw new Error(`Failed to delete contact: ${response.statusText}`);
    }

    const row = document.querySelector(`tr[data-id='${contactId}']`);
    if (row) row.remove();
  } catch (err) {
    console.error("Error deleting contact:", err);
    alert("Failed to delete contact. See console for details.");
  }
}
