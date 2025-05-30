# =============================================================================
# FIXED API GATEWAY CONFIGURATION
# =============================================================================
# Remove integration responses for AWS_PROXY integrations
# Lambda handles the entire response when using AWS_PROXY

# GET method for retrieving all contacts - WORKING VERSION
resource "aws_api_gateway_method" "get_contacts" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "GET"
  authorization = "NONE"
}

# Forward GET requests to Lambda function
resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.get_contacts.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_contacts.invoke_arn
}

# REMOVE THIS - Don't define method response for AWS_PROXY
# resource "aws_api_gateway_method_response" "get_200" { ... }

# REMOVE THIS - Don't define integration response for AWS_PROXY  
# resource "aws_api_gateway_integration_response" "get_200" { ... }

# =============================================================================
# SAME FIX FOR POST METHOD
# =============================================================================

resource "aws_api_gateway_method" "post_contact" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_post" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.post_contact.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.crm_handler.invoke_arn
}

# REMOVE THESE FOR POST TOO:
# resource "aws_api_gateway_method_response" "post_200" { ... }
# resource "aws_api_gateway_integration_response" "post_200" { ... }

# =============================================================================
# SAME FIX FOR DELETE METHOD  
# =============================================================================

resource "aws_api_gateway_method" "delete_contact" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contact_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_delete" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contact_id.id
  http_method             = aws_api_gateway_method.delete_contact.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.crm_handler.invoke_arn
}

# REMOVE THESE FOR DELETE TOO:
# resource "aws_api_gateway_method_response" "delete_200" { ... }
# resource "aws_api_gateway_integration_response" "delete_200" { ... }

# =============================================================================
# KEEP THE OPTIONS METHODS AS-IS
# =============================================================================
# OPTIONS methods use MOCK integration, so they DO need method/integration responses
# Keep all your OPTIONS configuration exactly as it is - that's correct!

# =============================================================================
# UPDATE YOUR DEPLOYMENT TRIGGERS
# =============================================================================

resource "aws_api_gateway_deployment" "crm_api_deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda_post,
    aws_api_gateway_integration.lambda_get,
    aws_api_gateway_integration.lambda_delete,
    aws_api_gateway_integration.options_contacts,
    aws_api_gateway_integration.options_contact_id,
    aws_api_gateway_integration_response.options_contacts_200,
    aws_api_gateway_integration_response.options_contact_id_200
    # Remove the AWS_PROXY integration responses from depends_on
  ]
  
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  stage_name  = "dev" 

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contacts.id,
      aws_api_gateway_resource.contact_id.id,
      aws_api_gateway_method.options_contacts.id,
      aws_api_gateway_method.options_contact_id.id,
      aws_api_gateway_method.get_contacts.id,
      aws_api_gateway_method.post_contact.id,
      aws_api_gateway_method.delete_contact.id,
      aws_api_gateway_integration.options_contacts.id,
      aws_api_gateway_integration.options_contact_id.id,
      aws_api_gateway_integration.lambda_get.id,
      aws_api_gateway_integration.lambda_post.id,
      aws_api_gateway_integration.lambda_delete.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}