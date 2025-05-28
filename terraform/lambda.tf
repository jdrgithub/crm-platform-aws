resource "aws_lambda_function" "crm_handler" {
    function_name   = "${var.project_name}-handler"
    role            = aws_iam_role.lambda_exec_role.arn
    handler         = "handlers.create_contact.lambda_handler"
    runtime         = "python3.12"

    filename        = "${path.module}/lambda_function.zip"
    source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

    environment {
        variables = {
            DYNAMODB_TABLE = aws_dynamodb_table.crm_contacts.name
            ENV            = var.environment
        }
    }

    tags = {
        Name        = "CRM Lambda Handler"
        Environment = var.environment
    }
}

resource "aws_lambda_function" "get_contacts" {
    function_name   = "${var.project_name}-get_contacts"
    runtime         = "python3.12"
    filename        = "${path.module}/lambda_function.zip"
    source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
    handler         = "handlers.get_contacts.lambda_handler"
    role            = aws_iam_role.lambda_exec_role.arn
    timeout         = 10

    environment {
        variables = {
            DYNAMODB_TABLE = aws_dynamodb_table.crm_contacts.name
        }
    }
}