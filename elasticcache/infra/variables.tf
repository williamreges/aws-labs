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