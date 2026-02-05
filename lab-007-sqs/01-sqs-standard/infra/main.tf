resource "aws_sqs_queue" "lab-sqs-queue" {
  name                      = var.sqs_name
  delay_seconds             = var.sqs_delay_seconds
  max_message_size          = var.sqs_max_message_size
  message_retention_seconds = var.sqs_message_retention_seconds
  receive_wait_time_seconds = var.sqs_receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.lab-sqs-queue-dlq.arn
    maxReceiveCount     = 4
  })

  tags = {
    Label       = local.label
    Environment = var.tag_environment
  }
}

resource "aws_sqs_queue" "lab-sqs-queue-dlq" {
  name                      = var.sqs_dlq_name
  delay_seconds             = var.dlq_delay_seconds
  max_message_size          = var.dlq_max_message_size
  message_retention_seconds = var.dlq_message_retention_seconds
  receive_wait_time_seconds = var.dlq_receive_wait_time_seconds

  tags = {
    Environment = var.tag_environment
  }
}
