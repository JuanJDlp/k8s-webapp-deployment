resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.s3_name
  tags   = var.tags
}

module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name
}

module "eks" {
  source               = "./modules/eks"
  eks_cluster_role_arn = module.iam.eks_role_arn
  node_role_arn        = module.iam.node_role_arn
  region               = var.region
  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  node_instance_type   = var.node_instance_type

  depends_on = [
    module.vpc,
    module.iam
  ]
}

module "lbc" {
  source = "./modules/lbc"

  lbc_arn = module.auth.lbc_role_arn
  region  = var.region
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id

  depends_on = [
    module.eks
  ]
}

module "auth" {
  source = "./modules/auth"

  cluster_name = var.cluster_name
}

module "vpc" {
  source = "./modules/vpc"

  region          = var.region
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_cidr        = var.vpc_cidr
}

resource "aws_dynamodb_table" "tfstate_table" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}
