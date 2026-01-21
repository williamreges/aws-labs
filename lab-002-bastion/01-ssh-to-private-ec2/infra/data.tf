data "aws_caller_identity" "aws_current" {}

data "aws_vpc" "vpc_selected" {
  filter {
    name   = var.vpc_selected_filter.nameTag
    values = [var.vpc_selected_filter.valueTag]
  }
}
data "aws_subnet" "public_subnet" {
  vpc_id = data.aws_vpc.vpc_selected.id
  filter {
    name   = var.public_subnet_selected_filter.nameTag
    values = [var.public_subnet_selected_filter.valueTag]
  }
}

data "aws_subnet" "private_subnet" {
  vpc_id = data.aws_vpc.vpc_selected.id
  filter {
    name   = var.public_subnet_selected_filter.nameTag
    values = [var.public_subnet_selected_filter.valueTag]
  }
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = [var.ami_selected_filter.owner]
  filter {
    name   = var.ami_selected_filter.filters[0].nameTag
    values = [var.ami_selected_filter.filters[0].valueTag]
  }
  filter {
    name   = var.ami_selected_filter.filters[1].nameTag
    values = [var.ami_selected_filter.filters[1].valueTag]
  }
}