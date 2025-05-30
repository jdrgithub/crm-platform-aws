# Create the nested resource: /contacts/{contact_id}
resource "aws_api_gateway_resource" "contact_id" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  parent_id   = aws_api_gateway_resource.contacts.id
  path_part   = "{contact_id}"
}

# Define the OPTIONS method (CORS preflight support)
resource "aws_api_gateway_method" "options_contact_id" {
  rest_api_id   = aws_api_gateway_rest_api.crm_api.id
  resource_id   = aws_api_gateway_resource.contact_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Use MOCK integration to simulate a CORS response
resource "aws_api_gateway_integration" "options_contact_id" {
  rest_api_id             = aws_api_gateway_rest_api.crm_api.id
  resource_id             = aws_api_gateway_resource.contact_id.id
  http_method             = aws_api_gateway_method.options_contact_id.http_method
  type                    = "MOCK"
  request_templates       = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method response headers to expose in browser
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration response: what values to return for those headers
resource "aws_api_gateway_integration_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.crm_api.id
  resource_id = aws_api_gateway_resource.contact_id.id
  http_method = "OPTIONS"
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
  }
}
