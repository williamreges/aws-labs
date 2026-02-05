variable "region" {
  type        = string
  description = "AWS region"
  default     = "sa-east-1"
}

variable "sqs_delay_seconds" {
  type        = number
  description = "Delay seconds for the main SQS queue"
  default     = 90
}

variable "sqs_max_message_size" {
  type        = number
  description = "Maximum message size (bytes) for the main SQS queue"
  default     = 2048
}

variable "sqs_message_retention_seconds" {
  type        = number
  description = "Message retention period (seconds) for the main SQS queue"
  default     = 86400
}

variable "sqs_receive_wait_time_seconds" {
  type        = number
  description = "Long polling wait time (seconds) for the main SQS queue"
  default     = 10
}

variable "dlq_delay_seconds" {
  type        = number
  description = "Delay seconds for the DLQ SQS queue"
  default     = 90
}

variable "dlq_max_message_size" {
  type        = number
  description = "Maximum message size (bytes) for the DLQ SQS queue"
  default     = 2048
}

variable "dlq_message_retention_seconds" {
  type        = number
  description = "Message retention period (seconds) for the DLQ SQS queue"
  default     = 86400
}

variable "dlq_receive_wait_time_seconds" {
  type        = number
  description = "Long polling wait time (seconds) for the DLQ SQS queue"
  default     = 10
}

variable "sqs_name" {
  type        = string
  description = "Nome da fila SQS principal"
  default     = "lab-sqs-queue"
}

variable "sqs_dlq_name" {
  type        = string
  description = "Nome da fila DLQ (dead-letter)"
  default     = "lab-sqs-standard-dlq"
}

variable "tag_environment" {
  type        = string
  description = "Tag Environment usada nas resources"
  default     = "lab"
}

