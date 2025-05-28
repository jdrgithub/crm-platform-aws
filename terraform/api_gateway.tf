resource "aws_api_gateway_rest_api" "crm_api" {
    name        = "${var.project_name}-api"
    description = "Public API for CRM Lambda"
}

resource "aws_api_gateway_resource" "contacts" {
    rest_api_id = aws_api_gateway_rest_api.crm_api.id
    parent_id   = aws_api_gateway_rest_api.crm_api.root_resource_id
    path_part   = "contacts"
}

resource "aws_api_gateway_method" "post_contact" {
    rest_api_id     = aws_api_gateway_rest_api.crm_api.id
    resource_id     = aws_api_gateway_resource.contacts.id
    http_method     = "POST"
    authorization   = "NONE"
}

resource "aws_api_gateway_integration" "lambda_post" {
    rest_api_id = aws_api_gateway_rest_api.crm_api.id
    resource_id = aws_api_gateway_resource.contacts.id
    http_method = aws_api_gateway_method.post_contact.http_method

    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = aws_lambda_function.crm_handler.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw" {
    statement_id    = "AllowAPIGatewayInvoke"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.crm_handler.function_name
    principal       = "apigateway.amazonaws.com"
    source_arn      = "${aws_api_gateway_rest_api.crm_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "crm_api_deploy" {
    depends_on  = [aws_api_gateway_integration.lambda_post, aws_api_gateway_integration.lambda_get]
    rest_api_id = aws_api_gateway_rest_api.crm_api.id
}

resource "aws_api_gateway_stage" "crm_stage" {
    rest_api_id = aws_api_gateway_rest_api.crm_api.id
    stage_name      = var.environment
    deployment_id   = aws_api_gateway_deployment.crm_api_deploy.id
}

resource "aws_api_gateway_method" "get_contacts" {
    rest_api_id     = aws_api_gateway_rest_api.crm_api.id
    resource_id     = aws_api_gateway_resource.contacts.id
    http_method     = "GET"
    authorization   = "NONE"
}

resource "aws_api_gateway_integration" "lambda_get" {
    rest_api_id             = aws_api_gateway_rest_api.crm_api.id
    resource_id             = aws_api_gateway_resource.contacts.id
    http_method             = aws_api_gateway_method.get_contacts.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = aws_lambda_function.get_contacts.invoke_arn

}

resource "aws_lambda_permission" "allow_apigw_get" {
    statement_id    = "AllowAPIGatewayInvokeGet"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.get_contacts.function_name
    principal       = "apigateway.amazonaws.com"
    source_arn      = "${aws_api_gateway_rest_api.crm_api.execution_arn}/*/*"
}