const endpoint = "https://mn3vl1gj67.execute-api.us-east-1.amazonaws.com/dev/contacts";

// Load contacts on page load
function loadContacts() {
  fetch(endpoint)
    .then(response => response.json())
    .then(data => {
      const tbody = document.getElementById("contacts-body");
      tbody.innerHTML = ""; // Clear existing rows
      data.forEach(contact => {
        const row = document.createElement("tr");
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
        `;
        tbody.appendChild(row);
      });
    })
    .catch(err => {
      document.body.innerHTML += `<p style="color:red">Error loading contacts: ${err}</p>`;
      console.error("Failed to load contacts:", err);
    });
}

document.addEventListener("DOMContentLoaded", () => {
  loadContacts();

  const form = document.getElementById("contact-form");
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const formData = new FormData(form);
    const contact = Object.fromEntries(formData.entries());

    try {
      const creds = await getAWSTemporaryCredentials();

      const res = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Amz-Date": creds.timestamp,
          Authorization: creds.authHeader,
          "X-Amz-Security-Token": creds.sessionToken
        },
        body: JSON.stringify(contact)
      });

      if (!res.ok) throw new Error(await res.text());

      form.reset();
      loadContacts();
    } catch (err) {
      alert("Error submitting contact: " + err.message);
      console.error("POST error:", err);
    }
  });
});
