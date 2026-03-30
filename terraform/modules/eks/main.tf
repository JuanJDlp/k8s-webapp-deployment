resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids


  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  ami_type  = "AL2023_x86_64_STANDARD" # Amazon Linux 2023 Standard — EKS selects latest recommended AMI automatically
  disk_size = 20                        # Tamaño del disco raíz en GB (default 20GB)

  update_config {
    max_unavailable = 1 # Número máximo de nodos que pueden estar indisponibles durante una actualización
  }
}

# VPC CNI — asigna IPs de tu VPC directamente a los pods.
# Cada pod obtiene una IP real de tu subnet, no una IP de overlay.
# Esto es lo que hace que "kubectl describe pod" muestre una IP 10.0.x.x.
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# CoreDNS — el servidor DNS interno del cluster.
# Permite que un pod resuelva "backend.default.svc.cluster.local".
# Sin CoreDNS, los Services de Kubernetes no resuelven por nombre.
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # CoreDNS requiere que ya existan nodos para schedulear sus pods.
  depends_on = [aws_eks_node_group.this]
}

# kube-proxy — mantiene las reglas iptables en cada nodo.
# Cuando haces curl a una ClusterIP, kube-proxy es quien
# redirige ese tráfico al pod correcto detrás del Service.
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}