ir (hide)
Running in /var/jenkins_home/workspace/crm-platform-aws_main/terraform
[Pipeline] {
[Pipeline] sh
+ terraform plan -out=tfplan

Error: Reference to undeclared resource

  on api_gateway.tf line 26, in resource "aws_api_gateway_integration" "lambda_post":
  26:     uri                     = aws_lambda_function.crm_handler.invoke_arn

A managed resource "aws_lambda_function" "crm_handler" has not been declared
in the root module.

Error: Reference to undeclared resource

  on api_gateway.tf line 32, in resource "aws_lambda_permission" "allow_apigw":
  32:     function_name   = aws_lambda_function.crm_handler.function_name

A managed resource "aws_lambda_function" "crm_handler" has not been declared
in the root module.

Error: Reference to undeclared resource

  on api_gateway.tf line 72, in resource "aws_api_gateway_integration" "lambda_get":
  72:     uri                     = aws_lambda_function.get_contacts.invoke_arn

A managed resource "aws_lambda_function" "get_contacts" has not been declared
in the root module.

Error: Reference to undeclared resource

  on api_gateway.tf line 90, in resource "aws_lambda_permission" "allow_apigw_get":
  90:     function_name   = aws_lambda_function.get_contacts.function_name

A managed resource "aws_lambda_function" "get_contacts" has not been declared
in the root module.

Error: Reference to undeclared resource

  on api_gateway.tf line 102, in resource "aws_apigatewayv2_integration" "cors":
 102:   api_id             = aws_apigatewayv2_api.crm_api.id

A managed resource "aws_apigatewayv2_api" "crm_api" has not been declared in
the root module.
[Pipeline] }
[Pipeline] // dir
[Pipeline] }