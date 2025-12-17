variable "aws_profile" {
  type        = string
  description = ""
  default     = "aulaaws"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone to deploy resources in."
  default     = "sa-east-1a"
}

variable "region" {
  type        = string
  description = ""
  default     = "sa-east-1"
}

variable "elasticache_auth_token" {
  type        = string
  description = "Token used for Redis AUTH. Leave empty to disable."
  default     = "1234!"
  sensitive   = true
}