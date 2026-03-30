module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  # Dos AZs es el mínimo que EKS exige para alta disponibilidad del control plane.
  # Con una sola AZ, el cluster no se crea.
  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # NAT Gateway en CADA AZ — obligatorio cuando los nodos se distribuyen en múltiples AZs.
  # Si usas single_nat_gateway = true con 2+ AZs, los nodos sin NAT no pueden hacer outbound
  # y se quedan en "Creating" indefinidamente.
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true # obligatorio para que los nodos resuelvan el endpoint del cluster
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" #Hace que el Load Balancer no se borre al destruir el cluster, sino al destruir la VPC
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}