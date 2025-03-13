bucket         = "mf-commonsprod-terraform-state"
key            = "EP-CORE-PROD-APP-terraform.tfstate"
region         = "ap-south-1"
encrypt        = true
dynamodb_table = "terraform-lock"