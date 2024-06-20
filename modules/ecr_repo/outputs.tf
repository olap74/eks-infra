
output "ecr_repo_names" {
  description = "The names of the ECR repos that were created"
  # The result of for_each is a map, so we have to use a comprehension to generate an output list
  value = [for repo in aws_ecr_repository.this : repo.name]
}

output "ecr_repo_urls" {
  description = "The repository URLs of the ECR repos that were created"
  # The result of for_each is a map, so we have to use a comprehension to generate an output list
  value = [for repo in aws_ecr_repository.this : repo.repository_url]
}
