
resource "aws_ecr_repository" "this" {
  for_each = toset(var.services)

  name                 = "${var.repo_prefix}${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.tags
}
