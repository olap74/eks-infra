provider "aws" {
  alias = "resource"
  region  = local.resource_region
  profile = local.resource_profile
}
