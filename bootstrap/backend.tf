terraform {
  backend "s3" {
  bucket = "minombresuperonico-terraform-state"
  key = "backend-infra/terraform.tfstate"
  region = "us-east-1"
}
}
