##################################################################
# Local variables naming convention:
#
# locals {
#    module_name = {
#       variable_name = variable_value
#    }
# }

locals {
  env_name = "cluster-dev01"

  ### Modules configuration

  config-storage = {
    owner = "devops"
  }

  # Module eks-cluster
  eks-cluster = {
    eks_provisioner_iam_role_arn = "arn:aws:iam::851725521654:role/eks-provisioner"
    cluster_endpoint_public_access_cidrs = [
      "88.156.139.89/32", # VPN Gateway
      "88.156.139.0/24"   # Local IP
    ]
    cluster_version = "1.29"
  }

  # Module eks-node-groups
  eks-node-groups = {
    ami_type             = "CUSTOM"
    eks_worker_ami_owner = "602401143452"
    eks_worker_ami_name  = "amazon-eks-node-1.29-*"
    user_data = {
      pre_userdata = "sysctl -w net.ipv4.tcp_keepalive_time=120"
    }
    regular = {
      node_group_prefix = "all"
      instance_types    = ["t3.micro"]
      min_size          = 1
      max_size          = 3
      labels = {
        service = "all"
      }
      volume_size = 10
    }
  }

  # Module environment
  environment = {
    azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
    cidr            = "10.10.0.0/18"
    private_subnets = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
    public_subnets  = ["10.10.51.0/24", "10.10.52.0/24", "10.10.53.0/24"]

    enable_eks         = true
    enable_nat_gatevay = true

    one_nat_gateway_per_az = false
    owner                  = "devops"
    single_nat_gateway     = true
    tags = {
      product = "deveks",
    }
  }

  # Module iam
  iam = {
    service-irsa-role = {
      oidc_fully_qualified_subjects = []
      oidc_subjects_with_wildcards = [
        "system:serviceaccount:*:default",
      ]
      roles = [
        {
          cam = [
            "arn:aws:iam::851725521654:policy/ssm-core-eu-central-1"
          ]
        }
      ]
    }
  }


  # EKS Resources
  eks-resources = {
    cluster-autoscaler = {
      image_tag = "v1.21.0"
    }
    external-dns = {
      replicas             = 1
      extra_domain_filters = []
    }
    metrics-server = {
      image_tag = "v1.21.0"
    }
    node-termination-handler = {
      image_tag = "v1.21.0"
    }
  }
}
