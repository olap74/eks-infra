################################################################################
## Constants
################################################################################

locals {
  admin_arns = var.admin_arns

  bucket = format("%s-env-configs", var.env_name)

  component = "kubeconfig"

  default_tags = merge(var.tags, {
    account           = var.aws_profile
    owner             = var.owner
    terraform         = true
  })
}

################################################################################
## Resources
################################################################################

# provision s3 bucket
resource "aws_s3_bucket" "this" {
  bucket = local.bucket

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(local.default_tags, {
    Name = format ("kubeconfig store for %s", var.aws_profile)
  })
}

# resource "aws_s3_bucket_acl" "this" {
#   bucket = aws_s3_bucket.this.id
#   acl    = "authenticated-read"
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# allow admins to access kubeconfig
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json
  depends_on = [aws_s3_bucket.this]
}

# define bucket policy
data "aws_iam_policy_document" "bucket" {
  # allow concourse to list kubeconfigs
  statement {
    actions   = ["s3:ListBucket"]
    effect    = "Allow"
    resources = [aws_s3_bucket.this.arn]

    principals {
      type        = "AWS"
      identifiers = local.admin_arns
    }
  }

  # allow ci to manage kubeconfigs
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = local.admin_arns
    }
  }
}

# restrict acls to private
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on = [aws_s3_bucket_policy.this]
}
