output "cluster_name" {
  description = "Nombre del cluster EKS"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint del API server — usado por kubectl y los providers de Terraform"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA del cluster (base64)"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "configure_kubectl" {
  description = "Ejecuta este comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this.name}"
}