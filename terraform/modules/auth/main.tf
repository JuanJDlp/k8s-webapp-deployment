# Necesitamos el thumbprint TLS del OIDC endpoint para que IAM
# pueda verificar los tokens. aws_eks_cluster ya lo expone.
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  # La URL del issuer OIDC es única por cluster — EKS la genera al crear el cluster
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer

  # sts.amazonaws.com es quien va a validar los tokens — STS es el "audience"
  client_id_list = ["sts.amazonaws.com"]

  # El thumbprint TLS permite a IAM verificar que el token viene
  # realmente de tu cluster y no de un impostor
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}


# La trust policy es el corazón de IRSA.
# Le dice a IAM: "solo permite asumir este rol si el token JWT
# viene del OIDC de ESTE cluster y fue emitido para el Service
# Account 'aws-load-balancer-controller' en el namespace 'kube-system'"
data "aws_iam_policy_document" "lbc_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]  # no AssumeRole — es WebIdentity

    principals {
      type = "Federated"
      # El ARN del OIDC Provider que acabamos de crear
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      # La condición tiene formato: <oidc-issuer>:sub
      # "sub" es el subject del JWT — identifica el Service Account específico
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lbc" {
  name               = "${var.cluster_name}-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.lbc_assume_role.json
}

# La política oficial del LBC — define exactamente qué acciones
# puede hacer sobre EC2, ELB, WAF, Shield, etc.
# La descargamos directo del repo oficial para garantizar que
# está actualizada con la versión del LBC que instalaremos.
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lbc" {
  name   = "${var.cluster_name}-lbc-policy"
  policy = data.http.lbc_iam_policy.response_body
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}