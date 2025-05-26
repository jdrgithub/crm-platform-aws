resource "aws_dynamodb_table" "crm_contacts" {
    name            = "${var.project_name}-contacts"
    billing_mode    = "PAY_PER_REQUEST"

    hash_key        = "contact_id"

    attribute {
        name = "contact_id"
        type = "S"
    }

    tags = {
        Name        = "CRM Contacts Table"
        Environment = var.environment
    }

}
    

    