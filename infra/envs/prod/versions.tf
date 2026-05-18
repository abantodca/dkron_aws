# infra/envs/prod/versions.tf
# Pinneamos versiones para que el "funciona en mi laptop"
# sea idéntico al "funciona en GitHub Actions".

terraform {
  required_version = ">= 1.10" # 1.10+ requerido por backend S3 con use_lockfile = true

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Tags obligatorios del PDF 5.1 — se aplican a TODO recurso del provider.
# Cualquier recurso que cree Terraform los hereda automáticamente.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  }
}