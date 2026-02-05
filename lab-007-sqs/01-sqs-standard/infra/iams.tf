resource "aws_sqs_queue_policy" "lab-sqs-queue-policy" {
  queue_url = aws_sqs_queue.lab-sqs-queue.id
  policy = templatefile("${path.module}/policy/policy-sqs.json", {
    account_id = data.aws_caller_identity.aws_current.id
    region     = var.region
    queue_name = local.sqsname
  })
}