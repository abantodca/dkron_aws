# infra/envs/prod/main.tf

module "network" {
  source   = "../../modules/network"
  project  = var.project
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}

module "ecr" {
  source  = "../../modules/ecr"
  project = var.project
}

module "compute" {
  source               = "../../modules/compute"
  project              = var.project
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  vpc_cidr             = module.network.vpc_cidr
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids   = module.network.private_subnet_ids
  instance_type        = var.instance_type
  ssh_public_key       = var.ssh_public_key
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
  ecr_repository_arn   = module.ecr.repository_arn
  image_repo_param_arn = module.ecr.image_repo_param_arn
}
