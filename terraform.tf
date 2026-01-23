terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.5.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}
