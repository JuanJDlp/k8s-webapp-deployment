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