resource "aws_iam_role" "bastion_ssm_role" {
  name = "lab-bastion-redis-ssm-role"
  assume_role_policy = file("${path.module}/iam/trust/trust-execution-bastion.json")
  tags = {
    label = local.label
  }
}

resource "aws_iam_policy" "policy" {
  name        = "lab-bastion-redis-ssm-role"
  description = "Permissions policy Bastion"
  policy      = file("${path.module}/iam/policy/policy-execution-bastion.json")
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.bastion_ssm_role.name
  policy_arn = aws_iam_policy.policy.arn
}

# Attach da policy AmazonSSMManagedInstanceCore
# resource "aws_iam_role_policy_attachment" "bastion_ssm_policy" {
#   role       = aws_iam_role.bastion_ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# Instance Profile
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-redis-profile"
  role = aws_iam_role.bastion_ssm_role.name
}