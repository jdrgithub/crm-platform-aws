# terraform/cognito.tf

# Creates identity pool for unauthenticated access
resource "aws_cognito_identity_pool" "demo_pool" {
  identity_pool_name                = "crm-demo-identity-pool"
  allow_unauthenticated_identities  = true
}

# Creates role for unauthed Cognito users to assume
# aud -> only tokens from my ID pool can assume role
# amr -> only unauthed users can assume role
resource "aws_iam_role" "unauthenticated_role" {
  name = "crm-demo-unauth-role"

  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.demo_pool.id}"
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "unauthenticated"
          }
        }
      }
    ]
  }
  POLICY
}

# grants perms for role to call API gateway
# unauthed users (using cognito) can make requests to contact endpoint
resource "aws_iam_role_policy" "unauthenticated_policy" {
  name = "crm-demo-unauth-policy"
  role = aws_iam_role.unauthenticated_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "execute-api:Invoke"
        ],
        Resource = "*" # Later restrict to specific API Gateway ARN
      }
    ]
  })
}

# Purpose -> link identity pool to IAM role
# Creds from ID pool assigned to unauthed role
resource "aws_cognito_identity_pool_roles_attachment" "demo_roles" {
  identity_pool_id = aws_cognito_identity_pool.demo_pool.id

  roles = {
    unauthenticated = aws_iam_role.unauthenticated_role.arn
  }
}