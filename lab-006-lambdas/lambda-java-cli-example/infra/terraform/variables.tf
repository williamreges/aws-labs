variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "aulaaws"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "validadigitocpffunction"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "org.example.GeneratorDigitoCpfHandler::handleRequest"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "java17"
}

variable "jar_path" {
  description = "Relative path to the built jar file from the terraform folder"
  type        = string
  default     = "code/app.jar"
}

variable "publish" {
  description = "Whether to publish a new Lambda version when updating code"
  type        = bool
  default     = false
}

variable "enable_s3_invoke_permission" {
  description = "Create a lambda permission to allow S3 to invoke the function"
  type        = bool
  default     = false
}

variable "s3_source_account" {
  description = "Source account for S3 invoke permission (optional)"
  type        = string
  default     = ""
}

variable "s3_source_arn" {
  description = "Source ARN (bucket) for S3 invoke permission (optional)"
  type        = string
  default     = ""
}