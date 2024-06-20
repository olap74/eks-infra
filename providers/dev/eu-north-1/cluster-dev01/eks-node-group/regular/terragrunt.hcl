terraform {
  source = "../../../../../..//modules/eks-node-groups"
}

include {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env_vars.hcl"))
}

dependency "environment" {
  config_path = "../../environment"
  mock_outputs = {
    azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
    vpc = {
      vpc_id          = "vpc-00000000000000000"
      private_subnets = ["subnet-00000000000000000", "subnet-00000000000000001"]
    }
    metadata = {
      account     = "nonexistent"
      environment = "cluster-name"
      owner       = "someteam"
    }
  }
}

dependency "eks-cluster" {
  config_path = "../../eks-cluster"
  mock_outputs = {
    cluster = {
      cluster_certificate_authority_data = "LS0tLS=="
      cluster_endpoint                   = "https://00000000000000000000000000000000.aa1.us-east-1.eks.amazonaws.com"
      cluster_primary_security_group_id  = "sg-00000000000000000"
    }
    worker_roles = {
      default = {
        arn = "arn:aws:iam::000000000000:role/cam-default"
        id  = "worker-default"
      }
    }
    key_pair = {
      key_name = "cam"
    }
    worker_security_group = {
      id = "sg-0000000000000000"
    }
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals.eks-node-groups.regular,
  local.env_vars.locals.eks-node-groups,
  {
    environment       = local.env_vars.locals.env_name
    cluster_cert_data = dependency.eks-cluster.outputs.cluster.cluster_certificate_authority_data
    cluster_endpoint  = dependency.eks-cluster.outputs.cluster.cluster_endpoint
    key_pair_name     = dependency.eks-cluster.outputs.key_pair.key_name
    worker_sg         = dependency.eks-cluster.outputs.worker_security_group.id
    worker_roles      = dependency.eks-cluster.outputs.worker_roles
    node_group_prefix = local.env_vars.locals.eks-node-groups.regular.node_group_prefix
    azs               = dependency.environment.outputs.azs
    vpc_id            = dependency.environment.outputs.vpc.vpc_id
    env_metadata      = dependency.environment.outputs.metadata
    cluster_sg        = dependency.eks-cluster.outputs.cluster.cluster_primary_security_group_id
    node_subnet_ids   = dependency.environment.outputs.vpc.private_subnets
  }
)
