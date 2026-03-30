data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

# AmazonEKSClusterPolicy: permisos para que el control plane gestione
# recursos de red (ENIs, Security Groups) y pueda llamar a EC2/ELB APIs.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # los nodos son EC2, no EKS
    }
  }
}

resource "aws_iam_role" "eks_nodes" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}


resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each   = local.node_policies
  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

# Las tres políticas que todo nodo EKS necesita obligatoriamente:
locals {
  node_policies = {
    # Permite al kubelet registrarse en el cluster y reportar estado
    worker = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    # Permite al VPC CNI crear y gestionar ENIs para asignar IPs a pods
    vpc_cni = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    # Permite al kubelet hacer pull de imágenes desde ECR
    ecr = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
}