output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "The private subnet IDs for EKS worker nodes"
  value       = module.vpc.private_subnets
}
