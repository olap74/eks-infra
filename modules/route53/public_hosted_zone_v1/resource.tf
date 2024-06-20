#One resource in module is zone
resource "aws_route53_zone" "zone" {
  name    = var.zone_name
  comment = var.comment

  tags = local.tags
}
