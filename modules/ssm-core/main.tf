################################################################################
## Data Sources
################################################################################

data "aws_caller_identity" "this" {}

# lookup aws partition
data "aws_partition" "this" {}

################################################################################
## Constants
################################################################################

locals {
  tags = merge(var.tags)
}

################################################################################
## Resources
################################################################################

data "aws_iam_policy_document" "this" {
  statement {
    # This is the root break-glass IAM policy statement for managing the KMS CMK
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
    actions   = ["kms:*", ]
    resources = ["*", ]
  }
  statement {
    sid    = "Enable use of the key"
    effect = "Allow"
    principals {
      identifiers = var.admin_arns
      type        = "AWS"
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}


data "template_file" "this" {
  template = file("templates/default.json.tmpl")

  vars = {
    kmskey_arn = aws_kms_key.this.arn
  }
}

resource "aws_iam_policy" "policy" {
  name        = "ssm-core-${var.aws_region}"
  path        = "/"
  description = "policy for service SSM core"
  tags        = local.tags
  policy      = data.template_file.this.rendered
}

resource "aws_kms_key" "this" {
  description = "SSM KMS key"
  policy = data.aws_iam_policy_document.this.json
  enable_key_rotation = true
  tags = local.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/ssm-core-${var.aws_region}"
  target_key_id = aws_kms_key.this.key_id
}
