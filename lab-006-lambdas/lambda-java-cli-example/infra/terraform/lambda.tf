

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  filename      = local.jar_fullpath
  handler       = var.handler
  runtime       = var.runtime
  role          = aws_iam_role.lambda_role.arn
  publish       = var.publish

  source_code_hash = filebase64sha256(local.jar_fullpath)

  tags = {
    label       = local.label
    environment = local.environment
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_alias" "alias_dev" {
  name             = "dev"
  description      = "Development environment - always points to latest"
  function_name    = aws_lambda_function.this.function_name
  function_version = "$LATEST"
}
# resource "aws_lambda_permission" "s3_invoke" {
#   count = var.enable_s3_invoke_permission && length(trim(var.s3_source_arn)) > 0 ? 1 : 0
#
#   statement_id  = "AllowS3Invoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.this.function_name
#   principal     = "s3.amazonaws.com"
#
#   # optional condition
#   condition {
#     test     = "StringEquals"
#     variable = "AWS:SourceAccount"
#     values   = [var.s3_source_account]
#   }
#
#   qualifier = ""
# }
