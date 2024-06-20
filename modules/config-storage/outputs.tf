output "bucket" {
  description = "kubeconfig bucket info"
  value       = aws_s3_bucket.this
}

// output "kubeconfig" {
//   description = "kubeconfig map"
//   value       = yamldecode(data.aws_s3_bucket_object.kubeconfig.body)
// }

// output "kubeconfig_yaml" {
//   description = "kubeconfig yaml"
//   value       = data.aws_s3_bucket_object.kubeconfig.body
// }

// output "metadata" {
//   description = "workspace metadata"
//   value       = local.default_tags
// }
