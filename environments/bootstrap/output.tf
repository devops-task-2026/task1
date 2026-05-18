# bootstrap/outputs.tf
output "buckets_created" {
  value = {
    dev     = "devops-challenge-tfstate-dev"
    staging = "devops-challenge-tfstate-staging"
    prod    = "devops-challenge-tfstate-prod"
  }
}

output "dynamodb_tables_created" {
  value = {
    dev     = "devops-challenge-tfstate-lock-dev"
    staging = "devops-challenge-tfstate-lock-staging"
    prod    = "devops-challenge-tfstate-lock-prod"
  }
}