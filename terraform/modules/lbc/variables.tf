variable "lbc_arn" {
  type        = string
  description = "ARN del rol IRSA para el AWS Load Balancer Controller"
}

variable "region" {
    type        = string
    description = "La región de AWS donde se encuentra el cluster EKS"
}

variable "cluster_name" {
    type        = string
    description = "El nombre del cluster EKS"
}

variable "vpc_id" {
    type        = string
    description = "El ID de la VPC donde se encuentra el cluster EKS"
}