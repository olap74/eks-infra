################################################################################
## Data Sources
################################################################################

data "aws_caller_identity" "current" {}

# lookup aws partition
data "aws_partition" "this" {}

################################################################################
## Constants
################################################################################

locals {
  arns = [for roles in var.roles : roles]

  roles = [for roles in var.roles : [for role, managed_arns in roles: role ]]

  tags = merge(var.tags,  var.env_metadata)

  bucket_prefixes = {
    dev = "spt-cam"
    prod = "spp-cam"
    internal = "spi-cam"
    saas-fed-dev = "spfd-cam"
    saas-fed-prod = "spfp-cam"
  }
}
################################################################################
## Resources
################################################################################

# provision eks irsa roles

module "render_templates" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  default_file_type = "text/plain"
  base_dir = "${path.module}/templates"
  template_vars = {
    account          = data.aws_caller_identity.current.account_id
    cognito_userpool = var.enable_overall_cognito ? "*" : var.cognito_id
    region           = var.aws_region
    eks_cluster_name = var.environment
    s3_prefix        = local.bucket_prefixes[var.aws_profile]
    partition        = data.aws_partition.this.partition
  }
}

resource "aws_iam_policy" "policy" {
  for_each = {for v in toset(local.roles[0]) : v => v
              if (try(module.render_templates.files["${v}.json"], null) != null)}

  name        = "${var.environment}-${each.value}"
  path        = "/"
  description = "policy for service ${each.value}"
  tags        = local.tags
  policy      = module.render_templates.files["${each.value}.json"].content
}

module "iam_iam-assumable-role-with-oidc" {
  for_each = toset(local.roles[0])
  source = "../iam-assumable-role-with-oidc"
  // source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  // version = "4.2.0"

  create_role                   = true
  number_of_role_policy_arns    = ((try(module.render_templates.files["${each.value}.json"], 0)) == 0 ? 0 : 1) + length([for i in [for roles in local.arns: [for managed_arns in roles[each.value] : managed_arns ] ][0] : i ])
  # TODO: incorporate this inside the map, right now its subject is injected to all roles
  oidc_fully_qualified_subjects = var.oidc_fully_qualified_subjects
  oidc_subjects_with_wildcards  = var.oidc_subjects_with_wildcards
  provider_url                  = var.cluster_oidc_issuer_url
  role_name                     = "${var.environment}-${each.value}"
  role_policy_arns              = concat([for i in [for roles in local.arns: [for managed_arns in roles[each.value] : managed_arns ] ][0] : i ], (try([aws_iam_policy.policy[each.value].arn], [])))
  tags                          = local.tags
}

resource "aws_iam_role_policy_attachment" "worker-attachment" {
  for_each = var.worker_role_id != "" ? aws_iam_policy.policy : {}
  role       = var.worker_role_id
  policy_arn = each.value.arn
}
