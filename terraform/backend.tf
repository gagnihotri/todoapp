terraform {
  backend "s3" {
    bucket         = "github-tf-bucket"
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-lock"
  }
}
