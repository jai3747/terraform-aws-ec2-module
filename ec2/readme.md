# Terraform Module for AWS EC2 Instances with Secrets Manager

## Overview
This Terraform module provisions AWS EC2 instances using configuration values stored in AWS Secrets Manager. It retrieves key parameters such as `ami_id`, `instance_type`, `subnet_id`, `kms_key_arn`, and `vpc_id` from Secrets Manager and ensures the EC2 instance name matches the secret name for seamless deployment.

## Features
- Fetches instance configuration from AWS Secrets Manager
- Creates EC2 instances with specified instance type, security groups, and key pairs
- Supports dynamic security group assignment based on VPC ID
- Attaches additional EBS volumes based on AMI and custom specifications
- Uses IAM roles and instance profiles for permission management
- Implements tagging for better resource tracking
- Enables metadata options for instance security

## Prerequisites
- Terraform installed (`>=1.9.2`)
- AWS CLI configured with appropriate credentials
- AWS Secrets Manager secrets created with required values
- Backend configuration set up for remote state management

## Module Inputs

| Name | Description | Type | Required |
|------|------------|------|----------|
| `instances` | Map of EC2 instance configurations | `map(object)` | Yes |
| `custom_tags` | Additional tags to apply to resources | `map(string)` | No |
| `app_name` | Application name used for IAM and resource naming | `string` | Yes |
| `enable_imds_v2` | Enable Instance Metadata Service v2 | `bool` | No (default: `true`) |
| `dedicated_host` | Launch instances on a dedicated host | `bool` | No (default: `false`) |
| `volume_type` | Default EBS volume type | `string` | No (default: `gp3`) |

## Secrets Manager Structure
Each secret should be named after the EC2 instance and contain the following key-value pairs:

```json
{
  "ami_id": "ami-0791c5aca3cffc113",
  "instance_type": "c6i.large",
  "subnet_id": "subnet-0453d1804042a42af",
  "kms_key_arn": "arn:aws:kms:ap-south-1:061051235441:key/56c0ea48-59ef-4633-ab00-d09a84c5ca44",
  "vpc_id": "vpc-0caa62404132422ae"
}
```

## Usage

```hcl
module "ec2_instances" {
  source       = "./modules/ec2"
  app_name     = "my-app"
  instances    = var.instances
  custom_tags  = { Environment = "production", Owner = "Team A" }
  enable_imds_v2 = true
}
```

## Security Groups
Security groups are dynamically assigned based on the VPC ID:
- **Linux instances**: Attached to `linux-onprem-sg`
- **Windows instances**: Attached to `windows-onprem-sg`

## IAM Policies
The module assigns the following IAM policies to instances:
- `AmazonEC2ReadOnlyAccess`
- `AmazonS3ReadOnlyAccess`
- `SecretsManagerReadWrite`
- `AmazonSSMReadOnlyAccess`
- `AmazonSSMManagedInstanceCore`

## Terraform Initialization
Run the following command to initialize Terraform with remote backend:

```sh
terraform init -backend-config=backend/mumbai/backend.tf
```

## Deployment Steps
1. Ensure Secrets Manager contains valid secrets for all instances.
2. Initialize Terraform backend:
   ```sh
   terraform init -backend-config=backend/mumbai/backend.tf
   ```
3. Validate the configuration:
   ```sh
   terraform validate
   ```
4. Plan the changes:
   ```sh
   terraform plan
   ```
5. Apply the changes:
   ```sh
   terraform apply -auto-approve
   ```

## Resource Creation
The module provisions the following resources:
- EC2 Instances with metadata security enabled
- Security Groups dynamically assigned based on VPC
- IAM Role and Instance Profile with predefined policies
- Network Interfaces with custom security group rules
- EBS Volumes dynamically attached based on AMI and additional disk configurations

## Cleanup
To destroy the resources created by this module, run:

```sh
terraform destroy -auto-approve
```

## License
This module is open-source and available under the MIT License.

