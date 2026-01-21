
output "vpc_aws" {
  value = data.aws_vpc.vpc_selected.id
}
output "subnet_public" {
  value = data.aws_subnet.public_subnet.id
}

output "ami" {
  value = data.aws_ami.amzn-linux-2023-ami.id
}