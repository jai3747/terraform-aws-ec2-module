
# Locals
locals {
  default_tags = {
    map-migrated = "migAKYMKZTLHB"
    Environment  = "production"
    Owner        = "Team A"
  }

  final_tags = merge(
    local.default_tags,
    var.custom_tags
  )

  # AMI devices mapping
  ami_devices = {
    for instance_key, instance in var.instances : instance_key => {
      for device in data.aws_ami.instance_ami[instance_key].block_device_mappings :
      device.device_name => {
        size   = try(device.ebs.volume_size, null)
        type   = try(device.ebs.volume_type, "gp3")
        in_use = true
      }
    }
  }

  # Filter additional disks
  filtered_additional_disks = {
    for instance_key, instance in var.instances : instance_key => [
      for disk in instance.additional_disks : disk
      if !contains(keys(local.ami_devices[instance_key]), disk.device_name)
    ]
  }

  # Map for additional EBS volumes
  filtered_ebs_volumes_map = {
    for pair in flatten([
      for instance_key, instance in var.instances : [
        for disk in local.filtered_additional_disks[instance_key] : {
          key          = "${instance_key}-${disk.device_name}"
          instance_key = instance_key
          device_name  = disk.device_name
          size         = disk.size
        }
      ]
    ]) : pair.key => pair
  }

  instance_secrets = {
    for instance_name, instance_data in var.instances : instance_name => jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[instance_name].secret_string)
  }

  instance_vpc_ids = {
    for instance_name, _ in var.instances : instance_name => jsondecode(data.aws_secretsmanager_secret_version.instance_vpc_secrets[instance_name].secret_string)["vpc_id"]
  }

  map_migration_tag = {
    map-migrated = local.default_tags["map-migrated"]
  }

  final_app_name = data.aws_region.current.name == "ap-south-2" ? "${var.app_name}-DR" : var.app_name

  policies = {
    "ec2_full_access"             = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    "s3_full_access"              = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    "secrets_manager_full_access" = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    "ssm_access"                  = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
    "system_manager"              = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  ami_ids_from_secrets = {
    for instance_name, instance_data in var.instances : instance_name =>
    jsondecode(data.aws_secretsmanager_secret_version.instance_secrets[instance_name].secret_string)["ami_id"]
  }
}
