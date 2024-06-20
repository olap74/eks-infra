locals {
  tags = merge({
    Terraform = "true",
    Product   = "EKSDEV",
    },
  var.tags, )
}
