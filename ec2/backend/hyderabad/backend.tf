bucket         = "mf-commonsprod-hyd-terraform-state"
key            = "EPCORE-PROD-APP-terraform.tfstate"
region         = "ap-south-2"
encrypt        = true
dynamodb_table = "terraform-lock"
skip_region_validation = true