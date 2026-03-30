terraform {
  backend "s3" {
  bucket = "tf-state-k8s-webapp-deployment-juanj"
  key = "backend-infra/terraform.tfstate"
  region = "us-east-1"
}
}