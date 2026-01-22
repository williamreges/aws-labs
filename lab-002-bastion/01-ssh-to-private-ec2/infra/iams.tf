#============ IAM BASTION==================
#=== ROLE
resource "aws_iam_role" "bastion_role" {
  name               = "lab-${local.name}-role"
  assume_role_policy = file("${path.module}/iam/trust/trust-execution-bastion.json")
  tags = {
    environment = local.tag_environment
  }
}

# # === POLICY
resource "aws_iam_policy" "bastion_policy" {
  name        = "lab-${local.name}-policy"
  description = "Permissions policy Bastion"
  policy      = file("${path.module}/iam/policy/policy-execution-bastion.json")
  tags = {
    environment = local.tag_environment
  }
}

# # ATACHMENT POLICY TO ROLE
resource "aws_iam_role_policy_attachment" "attach_role_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_policy.arn
  depends_on = [
    aws_iam_role.bastion_role,
    aws_iam_policy.bastion_policy
  ]
}

# # Instance Profile
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "lab-${local.name}-profile"
  role = aws_iam_role.bastion_role.name
  depends_on = [
    aws_iam_role_policy_attachment.attach_role_policy
  ]
  tags = {
    environment = local.tag_environment
  }
}