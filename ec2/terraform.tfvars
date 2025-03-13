app_name    = "EPC-APP-PROD"
environment = "prod"
instances = {
  "MMFSS-PLDACC1"={
    name          = "MMFSS-PLDACC1"
    # ami_id        = "ami-0381230c1ecb27a51" # Replace with your AMI ID
    # instance_type = "c6a.2xlarge"
    # subnet_id     = "subnet-024272c976ec4c3ff" # Replace with your subnet ID
    Onprem-IP     = "172.30.8.66"
    # Dedicated Host
    dedicated_host = true
    user_data      = <<-EOF
                       <powershell>
                       $dir = $env:TEMP + "\ssm"
                       New-Item -ItemType directory -Path $dir -Force
                       cd $dir
                       (New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe", $dir + "\AmazonSSMAgentSetup.exe")
                       Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait
                       </powershell>
                       EOF
    root_disk = {
      size = 200
    }
    additional_disks = [
      {
        device_name = "xvdb"
        size        = 50
      },
      {
        device_name = "xvdc"
        size        = 25
      },
      {
        device_name = "xvdd"
        size        = 25
      }
    ]
    # Ingress rules for first instance
    ingress_rules = [
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.60/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.61/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.64/32"]
      },
    ]
    # Egress rules for first instance
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  },
  
  "MMFSS-PLAHR1"={
    name          = "MMFSS-PLAHR1"
    # ami_id        = "ami-0381230c1ecb27a51" # Replace with your AMI ID
    # instance_type = "t3a.xlarge"
    # subnet_id     = "subnet-024272c976ec4c3ff" # Replace with your subnet ID
    Onprem-IP     = "172.30.9.244"
    # Dedicated Host
    dedicated_host = true
    user_data      = <<-EOF
                      <powershell>
                      $dir = $env:TEMP + "\ssm"
                      New-Item -ItemType directory -Path $dir -Force
                      cd $dir
                      (New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe", $dir + "\AmazonSSMAgentSetup.exe")
                      Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait
                      </powershell>
                      EOF
    root_disk = {
      size = 300
    }
    additional_disks = [
      {
        device_name = "xvdb"
        size        = 240
      }
    ]
    # Ingress rules for first instance
    ingress_rules = [
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.60/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.61/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.64/32"]
      },
    ]
    # Egress rules for first instance
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  },
  
  # "MMFSS-IANDS-APP"={
  #   name          = "MMFSS-IANDS-APP"
  #   # ami_id        = "ami-0381230c1ecb27a51" # Replace with your AMI ID
  #   # instance_type = "t3a.xlarge"
  #   # subnet_id     = "subnet-024272c976ec4c3ff" # Replace with your subnet ID
  #   Onprem-IP     = "172.30.0.128"
  #   # Dedicated Host
  #   dedicated_host = false
  #   user_data      = <<-EOF
  #                     <powershell>
  #                     $dir = $env:TEMP + "\ssm"
  #                     New-Item -ItemType directory -Path $dir -Force
  #                     cd $dir
  #                     (New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe", $dir + "\AmazonSSMAgentSetup.exe")
  #                     Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait
  #                     </powershell>
  #                     EOF
  #   root_disk = {
  #     size = 250
  #   }
  #   additional_disks = [
  #     {
  #       device_name = "xvdb"
  #       size        = 100
  #     },
  #   ]
  #   # Ingress rules for first instance
  #   ingress_rules = [
  #     {
  #       from_port   = 3389
  #       to_port     = 3389
  #       protocol    = "tcp"
  #       cidr_blocks = ["192.168.59.60/32"]
  #     },
  #     {
  #       from_port   = 3389
  #       to_port     = 3389
  #       protocol    = "tcp"
  #       cidr_blocks = ["192.168.59.61/32"]
  #     },
  #     {
  #       from_port   = 3389
  #       to_port     = 3389
  #       protocol    = "tcp"
  #       cidr_blocks = ["192.168.59.64/32"]
  #     },
  #   ]
  #   # Egress rules for first instance
  #   egress_rules = [
  #     {
  #       from_port   = 0
  #       to_port     = 0
  #       protocol    = "-1"
  #       cidr_blocks = ["0.0.0.0/0"]
  #     }
  #   ]
  # },
  
  "MMFSS-PLACORE1"={
    name          = "MMFSS-PLACORE1"
    # ami_id        = "ami-0381230c1ecb27a51" # Replace with your AMI ID
    # instance_type = "t3a.xlarge"
    # subnet_id     = "subnet-024272c976ec4c3ff" # Replace with your subnet ID
    Onprem-IP     = "172.30.21.216"
    # Dedicated Host
    dedicated_host = false
    user_data      = <<-EOF
                     <powershell>
                     $dir = $env:TEMP + "\ssm"
                     New-Item -ItemType directory -Path $dir -Force
                     cd $dir
                     (New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe", $dir + "\AmazonSSMAgentSetup.exe")
                     Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait
                     </powershell>
                     EOF
    root_disk = {
      size = 200
    }
    additional_disks = [
      {
        device_name = "xvdb"
        size        = 500
      },
      {
        device_name = "xvdc"
        size        = 100
      },
      {
        device_name = "xvdd"
        size        = 250
      },
    ]
    # Ingress rules for first instance
    ingress_rules = [
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.60/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.61/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.64/32"]
      },
    ]
    # Egress rules for first instance
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  },

  "MMFSS-IPAEP"={
    name          = "MMFSS-IPAEP"
    # ami_id        = "ami-0381230c1ecb27a51" # Replace with your AMI ID
    # instance_type = "t3a.2xlarge"
    # subnet_id     = "subnet-024272c976ec4c3ff" # Replace with your subnet ID
    Onprem-IP     = "172.30.24.222"
    # Dedicated Host
    dedicated_host = false
    user_data      = <<-EOF
                      <powershell>
                      $dir = $env:TEMP + "\ssm"
                      New-Item -ItemType directory -Path $dir -Force
                      cd $dir
                      (New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe", $dir + "\AmazonSSMAgentSetup.exe")
                      Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log") -Wait
                      </powershell>
                      EOF
    root_disk = {
      size = 250
    }
    additional_disks = [
      {
        device_name = "xvdb"
        size        = 500
      },
      {
        device_name = "xvdc"
        size        = 200
      },
      {
        device_name = "xvdd"
        size        = 100
      },
      {
        device_name = "xvde"
        size        = 100
      },
      {
        device_name = "xvdf"
        size        = 55
      },
      {
        device_name = "xvdg"
        size        = 100
      },
      {
        device_name = "xvdh"
        size        = 400
      },
      {
        device_name = "xvdi"
        size        = 100
      },
      {
        device_name = "xvdj"
        size        = 100
      },
      {
        device_name = "xvdk"
        size        = 300
      },
      {
        device_name = "xvdl"
        size        = 100
      },
      {
        device_name = "xvdm"
        size        = 100
      },
      {
        device_name = "xvdn"
        size        = 300
      }
    ]
    # Ingress rules for first instance
    ingress_rules = [
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.60/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.61/32"]
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["192.168.59.64/32"]
      },
    ]
    # Egress rules for first instance
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}
  
# KMS Key Arn
#kms_key_arn = "arn:aws:kms:ap-south-1:061051235441:key/56c0ea48-59ef-4633-ab00-d09a84c5ca44"

custom_tags = {
  Environment = "Production"
  Finops      = "EP"
  Application = "EPC"
  app = "true"
   backup  = "true"

}

# volume_type = "gp3"

# ALB Configuration
#create_lb = false # Set to true if you want to create the load balancer, if false leave the below configuration (don't modify)

# # List of subnets for the load balancer (replace with your actual subnet IDs)
# subnets = [
#   "subnet-01c782efdbe0e8693",
#   "subnet-064354fcd6d2e09de"
# ]

# # VPC Configuration
#vpc_id = "vpc-0caa62404132422ae"

# alb_ingress_rules = [
#   {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# ]

# alb_egress_rules = [
#   {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# ]

# alb_target_group_name     = "alb-target-group"
# alb_target_group_port     = 80
# alb_target_group_protocol = "HTTP"
# target_type               = "instance"
# health_check_path         = "/"
# health_check_interval     = 30

# alb_attachment_port     = 80
# alb_name                = "example-alb"
# alb_internal            = false
# alb_type                = "application"
# listener_port           = 80
# listener_protocol       = "HTTP"
# listener_default_action = "forward"

#