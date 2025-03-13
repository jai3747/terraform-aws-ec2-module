variable "instances" {
  description = "List of EC2 instance configurations"
  type = map(object({
    name = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))

    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    #  finops_tags = optional (string)
    instance_tags = optional(map(string), {})
    user_data     = string
    Onprem-IP     = string
    # Disk configuration
    root_disk = object({
      size = number # Root volume size
    })

    # Additional EBS disks to be attached to the instance
    additional_disks = list(object({
      device_name = string # Device name for additional EBS volumes
      size        = number # Size of the additional volume
    }))
  }))
  default = {}
}


variable "custom_tags" {
  type        = map(string)
  description = "Custom tags from the tfvars"
  default     = {}
}

variable "volume_type" {
  description = "Default volume type for the root and additional EBS volumes."
  type        = string
  default     = "gp3" # Default to gp3, can be overridden per disk
}

variable "enable_imds_v2" {
  description = "Enable or disable Instance Metadata Service v2"
  type        = bool
  default     = true
}
variable "app_name" {
  description = "Application Name"
  type        = string
  default     = "MMFSL"
}

variable "dedicated_host" {
  description = "Whether the server is dedicated or not"
  type        = bool
  default     = false
}
variable "environment" {
  description = "Specify the environment of that application"
  type        = string
  default     = "Dev"
}

