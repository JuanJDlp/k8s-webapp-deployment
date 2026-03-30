output "lbc_role_arn" {
  description = "ARN del rol IRSA para el AWS Load Balancer Controller"
  value       = aws_iam_role.lbc.arn
}