module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  aws_region         = var.aws_region
}

module "ec2" {
  source        = "./modules/ec2"
  project_name  = var.project_name
  environment   = var.environment
  instance_type = var.instance_type
  subnet_id     = module.vpc.subnet_id
  vpc_id        = module.vpc.vpc_id
  aws_region    = var.aws_region
}
