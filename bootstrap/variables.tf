variable "region" {
  type        = string
  description = "The aws region where objects will be created"
  default     = "us-east-1"
}

variable "s3_name" {
  type        = string
  description = "The name of the s3 bucket to be created"
  default     = "minombresuperonico-terraform-state"
}

variable "table_name" {
  type        = string
  description = "The name of the DynamoDB table to be created"
  default     = "tfstate-lock"
}

variable "tags" {
  description = "Common tags to be applied to all resources"

  type = map(string)
  default = {
    environment = "dev"
    project     = "k8s-webapp-deployment"
    owner       = "juanj"
  }

}

variable "billing_mode" {
  type        = string
  description = "The billing mode for the DynamoDB table"
  default     = "PAY_PER_REQUEST"
}
