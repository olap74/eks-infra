terraform {
  source = "../../../../..//modules/eks-cluster"

  extra_arguments "vars" {
    arguments = [
      "-var-file=${get_terragrunt_dir()}/aws-auth.tfvars.json"
    ]
    commands = get_terraform_commands_that_need_vars()
  }
}

include {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env_vars.hcl"))
}

dependencies {
  paths = ["../../../general/eks-provisioner/"]
}

dependency "environment" {
  config_path = "../environment"
  mock_outputs = {
    metadata = {
      account     = "nonexistent"
      environment = "cluster-name"
      owner       = "someteam"
    }
    azs = ["us-east-1"]
    vpc = {
      private_subnets_cidr_blocks = ["192.168.0.0/26", "192.168.0.64/26", "192.168.0.128/26"]
      public_subnets_cidr_blocks  = ["192.168.1.0/26", "192.168.1.64/26", "192.168.1.128/26"]
      vpc_id                      = "vpc-00000000000000000"
      node_subnets                = ["subnet-00000000000000000", "subnet-00000000000000001"]
      private_subnets             = ["subnet-00000000000000002", "subnet-00000000000000003"]
      public_subnets              = ["subnet-00000000000000004", "subnet-00000000000000005"]
      vpc_cidr_block              = "1.0.0.0/20"
    }
  }
}

dependency "config-storage" {
  config_path = "../config-storage"
  mock_outputs = {
    bucket = {
      id = "some-bucket-name"
    }
  }
}

dependency "ssm-core" {
  config_path = "../../regional/ssm_core"
  mock_outputs = {
    ssm_policy_arn  = "arn:aws:iam::000000000000:policy/ssm-core-region"
    ssm_policy_name = "ssm-core-region"
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals.eks-cluster,
  {
    eks_cluster_name      = local.env_vars.locals.env_name
    env_metadata          = dependency.environment.outputs.metadata
    private_subnets_cidrs = dependency.environment.outputs.vpc.private_subnets_cidr_blocks
    public_subnets_cidrs  = dependency.environment.outputs.vpc.public_subnets_cidr_blocks
    config_storage_bucket = dependency.config-storage.outputs.bucket.id
    vpc_id                = dependency.environment.outputs.vpc.vpc_id
    azs                   = dependency.environment.outputs.azs
    public_subnet_ids     = dependency.environment.outputs.vpc.public_subnets
    private_subnet_ids    = dependency.environment.outputs.vpc.private_subnets
    vpc_cidr_block        = dependency.environment.outputs.vpc.vpc_cidr_block
    ssm_policy_name       = dependency.ssm-core.outputs.ssm_policy_name
    ssm_policy_arn        = dependency.ssm-core.outputs.ssm_policy_arn
  }
)

