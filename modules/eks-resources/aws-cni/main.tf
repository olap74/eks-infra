################################################################################
## Providers
################################################################################

provider "kubectl" {
  host                   = local.kubeconfig.clusters.0.cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
  token                  = data.aws_eks_cluster_auth.this.token
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

data "aws_partition" "this" {}

data "template_file" "cni_role" {
  template = file("${path.module}/templates/aws-k8s-cni-role.tpl")
  vars = {
    version = var.cni_version 
  }
}

data "template_file" "cni_rb" {
  template = file("${path.module}/templates/aws-k8s-cni-rb.tpl")
  vars = {
    version = var.cni_version 
  }
}

data "template_file" "cni_sa" {
  template = file("${path.module}/templates/aws-k8s-cni-sa.tpl")
  vars = {
    version = var.cni_version 
  }
}

data "template_file" "cni_crd" {
  template = file("${path.module}/templates/aws-k8s-cni-crd.tpl")
  vars = {
    version = var.cni_version 
  }
}

data "template_file" "cni_ds" {
  template = file("${path.module}/templates/aws-k8s-cni-ds.tpl")
  vars = {
    version = var.cni_version
    region = var.aws_region
    source_account = local.source_account
  }
}

################################################################################
## References
################################################################################

locals {
  component = "cni"
  kubeconfig = yamldecode(var.kubeconfig)
  namespace = "kube-system"

  source_account = data.aws_partition.this.partition == "aws-us-gov" ? "013241004608" : "602401143452"
}

################################################################################
## Resources
################################################################################

# cni

resource "kubectl_manifest" "cni_role" {
  yaml_body = data.template_file.cni_ds.rendered
}

resource "kubectl_manifest" "cni_rb" {
  yaml_body = data.template_file.cni_ds.rendered
}

resource "kubectl_manifest" "cni_sa" {
  yaml_body = data.template_file.cni_ds.rendered
}

resource "kubectl_manifest" "cni_crd" {
  yaml_body = data.template_file.cni_ds.rendered
}

resource "kubectl_manifest" "cni_ds" {
  yaml_body = data.template_file.cni_ds.rendered
}
