resource "aws_vpc" "vpc-redis-lab" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "vpc-redis-lab"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc-redis-lab.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "private-subnet-redis-lab"
  }
}