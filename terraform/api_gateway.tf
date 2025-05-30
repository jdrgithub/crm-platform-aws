# =============================================================================
# API GATEWAY REST API CONFIGURATION
# =============================================================================
# This file configures an AWS API Gateway REST API for a CRM application.
# A key requirement is proper CORS handling for cross-origin requests from the frontend.
# Extra comments are included for clarity. 

# Main REST API resource -> the top-level API Gateway instance
resource "aws_api_gateway_rest_api" "crm_api" {
  name        = "${var.project_name}-api"
  description = "Public API for CRM Lambda"
}

# =============================================================================
# API RESOURCES (URL PATH STRUCTURE)
# =============================================================================
# These define the URL structure of the API

# Creates the /contacts resource path
# This will handle requests to: GET/POST /contacts
resource "aws_api_gateway_resource" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  parent_id   = aws_api_gateway_rest_api.crm_api.root_resource_id  # Attached to API root
  path_part   = "contacts"
}

# Creates the /contacts/{contact_id} resource path  
# This will handle requests to: GET/DELETE /contacts/123
resource "aws_api_gateway_resource" "contact_id" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  parent_id   = aws_api_gateway_resource.contacts.id  # Nested under /contacts
  path_part   = "{contact_id}"  # Path parameter that will be passed to Lambda
}

# =============================================================================
# CORS PREFLIGHT HANDLING - OPTIONS METHODS
# =============================================================================
# Browsers send OPTIONS requests before actual requests to check CORS permissions.
# These MOCK integrations respond to preflight requests without hitting Lambda.

# This is the OPTIONS method for /contacts/{contact_id} endpoint.
# Handles preflight requests for DELETE operations for contacts
resource "aws_api_gateway_method" "options_contact_id" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contact_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"  # No authentication required for CORS "preflight" pre-checking
}

# Defines what the OPTIONS method returns (200 status + CORS headers)
resource "aws_api_gateway_method_response" "options_contact_id_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.options_contact_id.http_method
  status_code = "200"

  # Tells API Gateway which headers method can return.
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# MOCK integration - returns hardcoded response without calling backend
# This is perfect for OPTIONS requests which just need to return CORS headers.
resource "aws_api_gateway_integration" "options_contact_id" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.options_contact_id.http_method
  type        = "MOCK"  # Returns mock response, doesn't call external service
  
  # Template that returns 200 status - triggers the integration response
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# Define the actual response returned by the MOCK integration.
# This sets the CORS headers that browsers need to allow cross-origin requests
resource "aws_api_gateway_integration_response" "options_contact_id_200" {
  depends_on  = [aws_api_gateway_integration.options_contact_id]
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.options_contact_id.http_method
  status_code = aws_api_gateway_method_response.options_contact_id_200.status_code

  # Set the actual CORS header values returned to the browser
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS,DELETE'",  # Allow these HTTP methods
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"   # Allow requests from this origin
  }

  response_templates = {
    "application/json" = ""  # Empty response body for OPTIONS
  }
}

# OPTIONS method for /contacts endpoint  
# Handles preflight requests for GET/POST operations for contacts
resource "aws_api_gateway_method" "options_contacts" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Define response structure for /contacts OPTIONS method.
resource "aws_api_gateway_method_response" "options_contacts_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options_contacts.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# MOCK integration for /contacts OPTIONS - same pattern as above
resource "aws_api_gateway_integration" "options_contacts" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options_contacts.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# Integration response for /contacts OPTIONS with CORS headers
resource "aws_api_gateway_integration_response" "options_contacts_200" {
  depends_on = [aws_api_gateway_integration.options_contacts]
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options_contacts.http_method
  status_code = aws_api_gateway_method_response.options_contacts_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# =============================================================================
# ACTUAL API METHODS - LAMBDA INTEGRATIONS  
# =============================================================================
# These handle the real business logic by forwarding requests to Lambda functions

# DELETE method for removing a specific contact
# Handles: DELETE /contacts/{contact_id}
resource "aws_api_gateway_method" "delete_contact" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contact_id.id
  http_method   = "DELETE"
  authorization = "NONE"  # No auth required - adjust based on security needs
}

# Integration that forwards DELETE requests to Lambda function
resource "aws_api_gateway_integration" "lambda_delete" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contact_id.id
  http_method             = aws_api_gateway_method.delete_contact.http_method
  integration_http_method = "POST"  # Lambda always uses POST regardless of original method
  type                    = "AWS_PROXY"  # Passes entire request to Lambda, Lambda handles response format
  uri                     = aws_lambda_function.crm_handler.invoke_arn
}

# Method response for successful DELETE operations
resource "aws_api_gateway_method_response" "delete_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.delete_contact.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true  # Required for CORS
  }
}

# Integration response - handles response from Lambda back to client
# With AWS_PROXY, Lambda controls most of the response, but we still need CORS headers.
resource "aws_api_gateway_integration_response" "delete_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.delete_contact.http_method
  status_code = aws_api_gateway_method_response.delete_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${var.frontend_origin}'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# POST method for creating new contacts
# Handles: POST /contacts
resource "aws_api_gateway_method" "post_contact" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "POST"
  authorization = "NONE"
}

# Forward POST requests to Lambda function
resource "aws_api_gateway_integration" "lambda_post" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.post_contact.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.crm_handler.invoke_arn
}

# Method response for successful POST operations  
resource "aws_api_gateway_method_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.post_contact.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Integration response for POST operations
resource "aws_api_gateway_integration_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.post_contact.http_method
  status_code = aws_api_gateway_method_response.post_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${var.frontend_origin}'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# GET method for retrieving all contacts
# Handles: GET /contacts
resource "aws_api_gateway_method" "get_contacts" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "GET"
  authorization = "NONE"
}

# Method response for successful GET operations
resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.get_contacts.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Forward GET requests to a separate Lambda function (read-only operations)
resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.get_contacts.http_method
  integration_http_method = "POST"  # Still POST to Lambda even for GET requests
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_contacts.invoke_arn  # Different Lambda for reads
}

# Integration response for GET operations
resource "aws_api_gateway_integration_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.get_contacts.http_method
  status_code = aws_api_gateway_method_response.get_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${var.frontend_origin}'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# =============================================================================
# LAMBDA PERMISSIONS
# =============================================================================
# Allow API Gateway to invoke Lambda functions

# Permission for API Gateway to invoke the main CRM handler (POST/DELETE operations)
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crm_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crm_api.execution_arn}/*/*"  # Allow from any method/resource
}

# Permission for API Gateway to invoke the GET contacts Lambda function
resource "aws_lambda_permission" "allow_apigw_get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_contacts.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crm_api.execution_arn}/*/*"
}

# =============================================================================
# API DEPLOYMENT
# =============================================================================
# This actually deploys API configuration to make it accessible

resource "aws_api_gateway_deployment" "crm_api_deploy" {
  # Wait for all integrations and responses to be created before deploying
  depends_on = [
    aws_api_gateway_integration.lambda_post,
    aws_api_gateway_integration.lambda_get,
    aws_api_gateway_integration.lambda_delete,
    aws_api_gateway_integration.options_contacts,
    aws_api_gateway_integration.options_contact_id,
    aws_api_gateway_integration_response.options_contacts_200,
    aws_api_gateway_integration_response.options_contact_id_200,
    aws_api_gateway_integration_response.get_200,
    aws_api_gateway_integration_response.post_200,
    aws_api_gateway_integration_response.delete_200
  ]
  
  rest_api_id = aws_api_gateway_rest_api.crm_api.id

  # Force new deployment when API configuration changes
  # Without this, changes to methods/integrations might not take effect
  triggers = {
    # Create hash of all important resource IDs - when any change, hash changes, deployment recreates
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

  # Create new deployment before destroying old one to avoid API downtime
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "crm_api_stage" {
  deployment_id = aws_api_gateway_deployment.crm_api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  stage_name    = "dev"
}