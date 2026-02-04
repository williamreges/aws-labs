resource "aws_sqs_queue" "lab-sqs-queue" {
  name                      = local.sqsname
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.lab-sqs-queue-dlq.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = local.tag_environment
  }
}

resource "aws_sqs_queue" "lab-sqs-queue-dlq" {
  name                      = local.sqsnamedlq
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = local.tag_environment
  }
}
