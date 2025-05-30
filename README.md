
---
# Serverless Contact Tracker (CRM)

This is a serverless customer relationship management (CRM) system designed to help users track contacts, recruiter conversations, job applications, follow-ups, and status updates. It consists of a frontend web application and a serverless backend deployed to AWS using Terraform and Jenkins.

This project was built as a personal tool to manage job search communication efficiently, and is structured with modularity, automation, and cloud-native principles in mind.

## Features

### Cloud-Native and Serverless by Design
- Deployed entirely on AWS Lambda, API Gateway, DynamoDB, Cognito, and S3.
- No servers, containers, or ongoing infrastructure management required.
- Supports full CRUD (Create, Read, Update, Delete) operations on contact data using Lambda functions and RESTful API Gateway routes.

### Real-Time Contact Tracking for Job Search or CRM Use
- Tracks detailed information about each contact, including name, email, phone, company, recruiter firm, position applied for, last contact date, next follow-up, notes, and status.
- Designed specifically to support job seekers managing recruiter outreach, interviews, and follow-ups in one place.
- Dynamically updates and renders the contact list directly in the browser.

### Clean, Validated Frontend Interface
- Static frontend served via S3 with lightweight HTML, JavaScript, and CSS.
- Real-time contact form validation powered by JustValidate.
- Responsive UI with dynamic table rendering, inline editing, and delete functionality.

### REST API Architecture with API Gateway (AWS_PROXY)
- Each API route is implemented as an AWS Lambda function and invoked through API Gateway using proxy integration.
- CORS configuration is handled directly in Lambda responses, allowing secure cross-origin calls from the browser.
- JSON-formatted responses and status codes follow standard HTTP conventions.

### Modular and Maintainable Python Codebase
- Contact data model implemented with a Python class for clean serialization and timestamp handling.
- Each Lambda handler (create, get, delete) is kept separate and modular for clarity and scalability.
- DynamoDB interactions abstracted into a service layer, keeping database logic isolated.

### Fully Automated CI/CD Pipeline
- Jenkins pipeline runs locally on a private Ubuntu server in a Docker container.
- Lambda functions are automatically packaged from source, zipped, and deployed using Terraform.
- Terraform applies changes idempotently and tracks infrastructure state, with only the S3 bucket protected from destruction.

### Browser-Based Auth with AWS Cognito
- Uses an AWS Cognito Identity Pool with unauthenticated guest access to provide temporary credentials for browser-based API requests.
- No hardcoded credentials or public API keys exposed in the frontend.
- All AWS SDK requests are signed securely using Cognito-issued temporary credentials.

### Reproducible and Cost-Efficient
- Designed to work entirely within the AWS Free Tier for personal use or experimentation.
- Infrastructure can be torn down and rebuilt automatically, with only persistent S3 assets retained.
- Works without relying on any managed container platforms or long-running compute resources.

---

## Deployment Model

This project is deployed using a **private Jenkins server** running inside a Docker container on an Ubuntu host. Jenkins automates the following:

1. Builds a Lambda zip package from the Python `src/` directory.
2. Copies the required source files into a temporary `lambda_build/` folder.
3. Runs `terraform apply` to update AWS infrastructure.
4. Uploads the zip to Lambda and applies changes via Terraform.

You will not be able to run this as-is unless you adapt it to your environment. However, the architecture and deployment strategy can be useful to model your own infrastructure.

---

## How to Adapt This Project

To run this project in your own AWS account:

1. **Clone the repository.**

2. **Set up AWS credentials** on your machine or Jenkins environment.

3. **Install Terraform** and configure remote or local backend.

4. **Edit the Terraform configuration** in the `terraform/` directory to reflect your desired region, naming conventions, and any additional resources.

5. **Use the `Jenkinsfile` as a reference**, or run these steps manually:
   - Copy handler files into a `lambda_build/` directory.
   - Create a zip archive of that folder.
   - Run `terraform apply` to provision the Lambda and API Gateway.
   - Upload `index.html`, `app.js`, and `aws-auth.js` to an S3 bucket for frontend access.

6. **Create a Cognito Identity Pool** (unauthenticated access) and use its ID in `aws-auth.js`.

7. **Test** the frontend and API Gateway endpoints to ensure the system is working.

---

## Notes on Design

- This project uses `AWS_PROXY` integration in API Gateway. As such, it **does not require** `aws_api_gateway_integration_response` or `aws_api_gateway_method_response` resources in Terraform for the Lambda-backed methods. These can interfere with proxy-style responses.
- CORS is manually implemented in each Lambda handler.
- All Lambda responses return fully-formed JSON with appropriate HTTP status codes and headers.

---

## Example Contact Fields

The DynamoDB table schema (noSQL) supports the following fields for each contact:

| Field             | Type     | Description                                 |
|------------------|----------|---------------------------------------------|
| contact_id        | string   | UUID assigned automatically                 |
| name              | string   | Required field                              |
| email             | string   | Required field                              |
| phone             | string   | Optional phone number                       |
| position_applied  | string   | Job title you applied for                   |
| company           | string   | Company name                                |
| recruiter_company | string   | Recruiter's company                         |
| last_contacted    | datetime | Last time you spoke to them (ISO format)    |
| next_follow_up    | date     | When to reach out next (ISO date format)    |
| status            | string   | Status (e.g., awaiting reply, ghosted)      |
| notes             | string   | Freeform field for notes                    |
| created_at        | datetime | Automatically set when record is created    |

---

## Limitations and Assumptions

- This is not a production-hardened app. Security, access control, and scalability have not been addressed.
- No authentication is implemented beyond Cognito guest access.
- Only basic validation is done on the frontend; backend assumes well-formed data.
- No pagination or search/filtering of contacts in DynamoDB (just a full scan).

---

## Extending the Project

This architecture can be extended in many directions:

- Add a login system (Cognito User Pools or a custom solution).
- Add edit/update functionality (currently only create and delete are implemented).
- Store interactions with each contact (multi-table design in DynamoDB).
- Add server-side pagination and search.
- Integrate notifications (e.g., send follow-up reminders via SES or SNS).
- Add CloudWatch alarms and dashboards for observability.

---

## License

This project is provided under the MIT License. See the `LICENSE` file for details.

