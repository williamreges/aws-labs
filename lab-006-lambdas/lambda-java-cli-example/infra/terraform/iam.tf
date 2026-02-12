resource "aws_iam_role" "lambda_role" {
  name = "aws-lambda-${var.function_name}-custom-role"

  assume_role_policy = templatefile("${path.module}/iamr/trust/policy-trust.json", {})
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.function_name}-inline-policy"
  role = aws_iam_role.lambda_role.id

  policy = templatefile("${path.module}/iamr/policy/policy.json",
    {
      region        = var.region
      account_id    = data.aws_caller_identity.current.account_id
      function_name = var.function_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
