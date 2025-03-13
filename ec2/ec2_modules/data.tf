
# Data Sources
data "aws_region" "current" {}

data "aws_subnet" "selected" {
  for_each = var.instances
  id       = local.instance_secrets[each.key]["subnet_id"]
}

data "aws_security_group" "linux_sg" {
  for_each = local.instance_vpc_ids

  filter {
    name   = "vpc-id"
    values = [each.value]
  }
  filter {
    name   = "group-name"
    values = ["linux-onprem-sg"]
  }
}

data "aws_security_group" "windows_sg" {
  for_each = local.instance_vpc_ids

  filter {
    name   = "vpc-id"
    values = [each.value]
  }
  filter {
    name   = "group-name"
    values = ["windows-onprem-sg"]
  }
}

data "aws_secretsmanager_secret_version" "instance_secrets" {
  for_each  = var.instances
  secret_id = each.key
}

data "aws_secretsmanager_secret_version" "instance_vpc_secrets" {
  for_each  = var.instances
  secret_id = each.value.name
}

data "aws_ami" "instance_ami" {
  for_each    = var.instances
  most_recent = true
  filter {
    name   = "image-id"
    values = [local.ami_ids_from_secrets[each.key]]
  }
}