# terraform/cognito.tf

# Identity pool for unauthenticated access
resource "aws_cognito_identity_pool" "demo_pool" {
  identity_pool_name                = "crm-demo-identity-pool"
  allow_unauthenticated_identities  = true
}

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