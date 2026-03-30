variable "region" {
  type        = string
  description = "The aws region where objects will be created"
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster to be created"
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version for the EKS cluster"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC to be created"
}

variable "node_instance_type" {
  type        = string
  description = "The EC2 instance type for the EKS worker nodes"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources"
}

variable "s3_name" {
  type        = string
  description = "The name of the s3 bucket to be created"
}

variable "table_name" {
  type        = string
  description = "The name of the DynamoDB table to be created"
}

variable "billing_mode" {
  type        = string
  description = "The billing mode for the DynamoDB table"
}
