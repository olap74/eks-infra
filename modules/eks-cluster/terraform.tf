provider "aws" {
  alias = "eks-provisioner"

  region  = var.aws_region
  profile = var.aws_profile

  assume_role {
    role_arn     = var.eks_provisioner_iam_role_arn
    session_name = "eks-provisioner"
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
