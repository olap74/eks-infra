resource "aws_iam_role" "this" {
  name               = local.role_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.this_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "this_inline" {
  name = "eksadmin"
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.this.json
}

# Most EKS modules will also handle the creation/removal of CloudWatch log groups for the control plane logging
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchLogsFullAccess"
}

# EKS modules should use KMS for encrypting secrets, and having power user access should grant
# sufficient privileges to manage the lifecycle of KMS keys.
resource "aws_iam_role_policy_attachment" "kms_power_user" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

output "eks_provisioner_iam_role" {
  value = aws_iam_role.this.arn
}
