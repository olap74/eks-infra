locals {
  tags = merge({
    Terraform = "true",
    Product   = "deveks",
    },
  var.tags)
}
