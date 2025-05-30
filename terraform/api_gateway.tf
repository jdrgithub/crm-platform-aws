# =============================================================================
# API GATEWAY REST API CONFIGURATION
# =============================================================================
resource "aws_api_gateway_rest_api" "crm_api" {
  name        = "${var.project_name}-api"
  description = "Public API for CRM Lambda"
}

# =============================================================================
# API RESOURCES
# =============================================================================
resource "aws_api_gateway_resource" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  parent_id   = aws_api_gateway_rest_api.crm_api.root_resource_id
  path_part   = "contacts"
}

resource "aws_api_gateway_resource" "contact_id" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  parent_id   = aws_api_gateway_resource.contacts.id
  path_part   = "{contact_id}"
}

# =============================================================================
# OPTIONS (CORS) FOR /contacts/{contact_id}
# =============================================================================
resource "aws_api_gateway_method" "options_contact_id" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contact_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_contact_id_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.options_contact_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options_contact_id" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.options_contact_id.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_integration_response" "options_contact_id_200" {
  depends_on  = [aws_api_gateway_integration.options_contact_id]
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = aws_api_gateway_method.options_contact_id.http_method
  status_code = aws_api_gateway_method_response.options_contact_id_200.status_code

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
# OPTIONS (CORS) FOR /contacts
# =============================================================================
resource "aws_api_gateway_method" "options_contacts" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

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

resource "aws_api_gateway_integration" "options_contacts" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contacts.id
  http_method = aws_api_gateway_method.options_contacts.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

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
# LAMBDA-INTEGRATED METHODS (AWS_PROXY)
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
  uri                     = aws_lambda_function.delete_contact.invoke_arn
}

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

resource "aws_api_gateway_method" "get_contacts" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.get_contacts.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_contacts.invoke_arn
}

# =============================================================================
# LAMBDA PERMISSIONS
# =============================================================================
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crm_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crm_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_contacts.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crm_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_gateway_delete" {
  statement_id  = "AllowExecutionFromAPIGatewayDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_contact.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crm_api.execution_arn}/*/DELETE/contacts/*"
}


# =============================================================================
# DEPLOYMENT + STAGE
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
  ]

  rest_api_id = aws_api_gateway_rest_api.crm_api.id

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
      "force-redeploy-${timestamp()}"
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "crm_api_stage" {
  deployment_id = aws_api_gateway_deployment.crm_api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  stage_name    = "dev"
}
