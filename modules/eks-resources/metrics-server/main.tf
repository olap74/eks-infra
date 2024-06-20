################################################################################
## Providers
################################################################################

# configure helm provider
provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.clusters.0.cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# configure kubernetes provider
provider "kubernetes" {
  host                   = local.kubeconfig.clusters.0.cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
  token                  = data.aws_eks_cluster_auth.this.token
}

################################################################################
## Data Sources
################################################################################

# import eks cluster auth info
data "aws_eks_cluster_auth" "this" {
  name     = local.kubeconfig.users.0.user.exec.args.3
}

################################################################################
## References
################################################################################

locals {

  component = "metrics-server"

  kubeconfig = yamldecode(var.kubeconfig)

  name = "${local.component}-${var.environment}"

  namespace = "kube-system"
}

################################################################################
## Resources
################################################################################

# provision helm chart
resource "helm_release" "this" {
  atomic    = true
  chart     = "${path.root}/chart"
  name      = local.name
  namespace = local.namespace
}
