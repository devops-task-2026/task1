terraform {
  backend "s3" {
    bucket         = "christian-devops-challenge-tfstate-dev"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "devops-challenge-tfstate-lock-dev"
    encrypt        = true
  }
}