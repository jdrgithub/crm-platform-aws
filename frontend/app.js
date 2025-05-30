// app.js

const endpoint = "https://mn3vl1gj67.execute-api.us-east-1.amazonaws.com/dev/contacts";

/**
 * Loads contacts from the API Gateway endpoint and populates the table
 */
function loadContacts() {
  fetch(endpoint)
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response.json();
    })
    .then(data => {
      const tbody = document.getElementById("contacts-body");
      tbody.innerHTML = ""; // Clear any existing rows

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

// Authenticate with Cognito and load data after credentials are ready
initializeAwsGuestAuth().then(() => {
  loadContacts();
});
