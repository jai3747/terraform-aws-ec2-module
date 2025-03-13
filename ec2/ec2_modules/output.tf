# Output all Linux security group IDs as a map
output "security_group_id_linux" {
  value = { for key, sg in data.aws_security_group.linux_sg : key => sg.id }
}

# Output all Windows security group IDs as a map
output "security_group_id_windows" {
  value = { for key, sg in data.aws_security_group.windows_sg : key => sg.id }
}


# outputs.tf
output "secret_manager_changes" {
  description = "Shows changes in secret values"
  value = {
    for instance_key, _ in var.instances : instance_key => {
      subnet_details = {
        current_value = nonsensitive(lookup(jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[instance_key].secret_string), "subnet_id", ""))
      }
      instance_details = {
        instance_type = nonsensitive(lookup(jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[instance_key].secret_string), "instance_type", ""))
        ami_id = nonsensitive(lookup(jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[instance_key].secret_string), "ami_id", ""))
      }
      vpc_details = {
        vpc_id = nonsensitive(lookup(jsondecode(data.aws_secretsmanager_secret_version.instance_vpc_secrets[instance_key].secret_string), "vpc_id", ""))
      }
    }
  }
}
# Specific output for subnet changes
output "subnet_changes" {
  description = "Specific subnet ID changes"
  value = {
    for instance_key, _ in var.instances : instance_key => {
      subnet_id = nonsensitive(lookup(jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[instance_key].secret_string), "subnet_id", ""))
    }
  }
}

# Main instance details with revealed values
output "instance_details" {
  description = "Instance configuration changes"
  value = {
    for instance_key, instance in aws_instance.web_server : instance_key => {
      subnet_id = nonsensitive(local.instance_secrets[instance_key]["subnet_id"])
      instance_type = nonsensitive(local.instance_secrets[instance_key]["instance_type"])
      ami_id = nonsensitive(local.instance_secrets[instance_key]["ami_id"])
    }
  }
}
output "debug_secret_content" {
  value = {
    for k, v in var.instances : k => jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[k].secret_string)
  }
  sensitive = true
}

output "ami_ids_from_secrets" {
  value = local.ami_ids_from_secrets
  sensitive = true
}

output "debug_each_value" {
  value = var.instances
}

output "ami_filter_debug" {
  value = {
    for k, v in var.instances : k => {
      filter_value = try(
        trimspace(jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[k].secret_string)["ami_id"]),
        "ami_id_not_found"
      )
    }
  }
  sensitive = true
}

output "latest_ami" {
  value = local.ami_ids_from_secrets
  sensitive = true
}


output "filtered_ebs_volumes_map" {
  value = local.filtered_ebs_volumes_map
}
# Add debug output to verify the filtering
output "ami_device_names" {
  value = local.ami_devices
  description = "Device names from the AMI"
}

# Debug outputs
output "ami_devices" {
  value = local.ami_devices
  description = "Devices coming from AMI"
}

output "filtered_additional_disks" {
  value = local.filtered_additional_disks
  description = "Additional disks that will be created (excluding ones that match AMI)"
}

output "final_device_mapping" {
  value = {
    ami_devices = local.ami_devices
    ebs_volumes = local.filtered_ebs_volumes_map
  }
  description = "Final mapping of all devices (both AMI and additional)"
}
output "volume_comparison" {
  value = {
    ami_volumes = local.ami_devices
    requested_volumes = {
      for k, v in var.instances : k => v.additional_disks
    }
    volumes_to_create = local.filtered_ebs_volumes_map
  }
  description = "Comparison of AMI volumes and volumes to be created"
}