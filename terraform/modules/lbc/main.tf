resource "kubernetes_service_account_v1" "lbc" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      # Esta anotación es el enlace entre Kubernetes e IAM.
      "eks.amazonaws.com/role-arn" = var.lbc_arn
    }

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
  }

}


resource "helm_release" "lbc" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"   # versión del Helm chart, esta es diferente a la versión del LBC

    # Le decimos al chart que NO cree el Service Account —
    # ya lo creamos arriba con Terraform para tener control total sobre él
    set {
    name  = "serviceAccount.create"
    value = "false"
    }

    set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account_v1.lbc.metadata[0].name
    }

    set {
    name  = "clusterName"
    value = var.cluster_name
    }

    set {
    name  = "region"
    value = var.region
    }

    set {
    name  = "vpcId"
    value = var.vpc_id
    }

  depends_on = [
    kubernetes_service_account_v1.lbc,
  ]
}