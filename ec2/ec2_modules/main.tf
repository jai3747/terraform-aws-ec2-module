resource "aws_instance" "web_server" {
  for_each                = var.instances
  ami                     = local.ami_ids_from_secrets[each.key]
  instance_type           = local.instance_secrets[each.key]["instance_type"]
  iam_instance_profile    = aws_iam_instance_profile.dynamic_instance_profiles.name
  disable_api_termination = true
  disable_api_stop        = true
  tenancy                 = var.dedicated_host ? "dedicated" : "default"

  metadata_options {
    http_tokens                 = var.enable_imds_v2 ? "required" : "optional"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  tags = merge(
    local.default_tags,
    {
      Name      = each.value.name
      Onprem-IP = each.value.Onprem-IP
    },
    var.custom_tags,
    try(each.value.instance_tags, {})
  )

  user_data = each.value.user_data

  network_interface {
    network_interface_id = aws_network_interface.web_server_eni[each.key].id
    device_index         = 0
  }

  # Root volume and AMI-based volumes only
  dynamic "ebs_block_device" {
    for_each = local.ami_devices[each.key]
    content {
      device_name           = ebs_block_device.key
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.type
      delete_on_termination = true
      encrypted             = true
      kms_key_id           = local.instance_secrets[each.key]["kms_key_arn"]
    }
  }

  lifecycle {
    ignore_changes = [
      network_interface,
      ebs_block_device
    ]
  }
}

# Additional EBS Volumes
resource "aws_ebs_volume" "ebs_volumes" {
  for_each = local.filtered_ebs_volumes_map

  availability_zone = data.aws_subnet.selected[each.value.instance_key].availability_zone
  size             = each.value.size
  type             = var.volume_type
  encrypted        = true
  kms_key_id       = local.instance_secrets[each.value.instance_key]["kms_key_arn"]

  tags = merge(
    local.final_tags,
    {
      Name = "${var.instances[each.value.instance_key].name}-${each.value.device_name}"
    }
  )
}

# Volume Attachments
resource "aws_volume_attachment" "volume_attachment" {
  for_each = local.filtered_ebs_volumes_map

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.ebs_volumes[each.key].id
  instance_id = aws_instance.web_server[each.value.instance_key].id

  # stop_instance_before_detaching = true
}

# Network Interface
resource "aws_network_interface" "web_server_eni" {
  for_each  = var.instances
  subnet_id = local.instance_secrets[each.key]["subnet_id"]
  security_groups = concat(
    [aws_security_group.dynamic_sg[each.key].id],
    flatten(
      [for rule in each.value.ingress_rules :
        rule.from_port == 22 ? [data.aws_security_group.linux_sg[each.key].id] : [data.aws_security_group.windows_sg[each.key].id]
      ]
    )
  )

  tags = merge(
    local.final_tags,
    {
      Name = "${each.value.name}"
    },
    var.custom_tags
  )
}

# Security Group
resource "aws_security_group" "dynamic_sg" {
  for_each = var.instances

  name        = "${each.value.name}-security-group"
  description = "Security group for instance ${each.key}"
  vpc_id      = local.instance_secrets[each.key]["vpc_id"]

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(local.final_tags)
}

# IAM Resources
resource "aws_iam_role" "dynamic_roles" {
  name = "${local.final_app_name}-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(local.final_tags)
}

resource "aws_iam_instance_profile" "dynamic_instance_profiles" {
  name = "${local.final_app_name}-iam-instance_profile"
  role = aws_iam_role.dynamic_roles.name
  tags = merge(local.final_tags)
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each   = local.policies
  role       = aws_iam_role.dynamic_roles.name
  policy_arn = each.value
}

# Tags
resource "aws_ec2_tag" "windows_sg_tags" {
  for_each    = data.aws_security_group.windows_sg
  resource_id = each.value.id
  key         = local.map_migration_tag["map-migrated"] != null ? "map-migrated" : ""
  value       = local.map_migration_tag["map-migrated"]
}

resource "aws_ec2_tag" "linux_sg_tags" {
  for_each    = data.aws_security_group.linux_sg
  resource_id = each.value.id
  key         = local.map_migration_tag["map-migrated"] != null ? "map-migrated" : ""
  value       = local.map_migration_tag["map-migrated"]
}
