resource "aws_iam_role" "bastion_ssm_role" {
  name = "lab-bastion-redis-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    label = "laboratorio-elasticache"
  }
}

# Attach da policy AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "bastion_ssm_policy" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-redis-profile"
  role = aws_iam_role.bastion_ssm_role.name
}