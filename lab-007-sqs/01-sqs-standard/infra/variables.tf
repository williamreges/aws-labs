
variable "availability_zone" {
  type        = string
  description = "The availability zone to deploy resources in."
  default     = "sa-east-1a"
}

variable "region" {
  type        = string
  description = "Região da AWS"
  default     = "sa-east-1"
}

variable "vpc_selected_filter" {
  description = "Nome da Tag e Valor da tag da VPC para filtro"
  type = object({
    nameTag  = string
    valueTag = string
  })
  default = {
    nameTag  = "tag:Name",
    valueTag = "vpc-lab"
  }
}

variable "public_subnet_selected_filter" {
  description = "Nome da Tag e Valor da tag da Public Subnet para filtro"
  type = object({
    nameTag  = string
    valueTag = string
  })
  default = {
    nameTag  = "tag:Name",
    valueTag = "public-subnet-1a"
  }
}

variable "private_subnet_selected_filter" {
  description = "Nome da Tag e Valor da tag da Private Subnet para filtro"
  type = object({
    nameTag  = string
    valueTag = string
  })
  default = {
    nameTag  = "tag:Name",
    valueTag = "private-subnet-1a"
  }
}

variable "ami_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_selected_filter" {
  description = "Fitro de AMI Amazon"
  type = object({
    owner = string
    filters = list(object({
      nameTag  = string
      valueTag = string
    }))
  })
  default = {
    owner = "amazon"
    filters = [
      {
        nameTag  = "architecture"
        valueTag = "x86_64"
      },
      {
        nameTag  = "name"
        valueTag = "al2023-ami-2023*"
      }
    ]
  }
}

variable "name_key_pair" {
  type        = string
  description = "Key Pair para o EC2 Bastino para acesso SSH"
  default     = "lab-key-pair" # Aqui é necesário informar seu key pair pessoal
}