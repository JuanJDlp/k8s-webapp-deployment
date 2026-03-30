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

variable "node_instance_type" {
  type        = string
  description = "The EC2 instance type for the EKS worker nodes"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the EKS cluster will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs for the EKS cluster"
}

variable "eks_cluster_role_arn" {
  type        = string
  description = "The ARN of the IAM role for the EKS control plane"
}

variable "node_role_arn" {
  type        = string
  description = "The ARN of the IAM role for the EKS node group"
}