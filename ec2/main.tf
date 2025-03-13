provider "aws" {
  region = var.aws_region
}

module "ec2" {
  source                    = "git::ssh://git@bitbucket.org/mmfss/mf-iac-modules.git//ec2"
  app_name                  = var.app_name
  instances                 = var.instances
  custom_tags               = var.custom_tags
}