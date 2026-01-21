#============ IAM BASTION==================
#=== ROLE
resource "aws_iam_role" "bastion_role" {
  name               = "lab-${local.name}-role"
  assume_role_policy = file("${path.module}/iam/trust/trust-execution-bastion.json")
  tags = {
    label = local.label
  }
}

# # === POLICY
resource "aws_iam_policy" "bastion_policy" {
  name        = "lab-${local.name}-policy"
  description = "Permissions policy Bastion"
  policy      = file("${path.module}/iam/policy/policy-execution-bastion.json")
}

# # ATACHMENT POLICY TO ROLE
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_policy.arn
}

# # Instance Profile
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "lab-${local.name}-profile"
  role = aws_iam_role.bastion_role.name
}