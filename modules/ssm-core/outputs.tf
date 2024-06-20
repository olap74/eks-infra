output "ssm_policy_name" {
  value       = aws_iam_policy.policy.name
  description = "Full Policy information"
}

output "ssm_policy_arn" {
  value       = aws_iam_policy.policy.arn
  description = "Full Policy information"
}
