resource "aws_iam_role" "lambda_exec_role" {
    name = "${var.project_name}-lambda-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect      = "Allow"
                Principal   = {
                    Service = "lambda.amazonaws.com"
                }
                Action      = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Name        = "Lambda Execution Role"
        Environment = var.environment
    }
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
    name = "${var.project_name}-lambda-dynamodb-policy"
    role = aws_iam_role.lambda_exec_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect      = "Allow"
                Action      = [
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:UpdateItem",
                    "dynamodb:DeleteItem",
                    "dynamodb:Scan",
                    "dynamodb:Query"
                ]
                Resource = aws_dynamodb_table.crm_contacts.arn
            },
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents:"
                ]
                Resource = "arn:aws:logs:*:*:*"
            }
        ]
    })
}