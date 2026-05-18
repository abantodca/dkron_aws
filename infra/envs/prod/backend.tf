# infra/envs/prod/backend.tf
# State remoto en S3 con locking nativo (use_lockfile = true).
# El archivo de lock es un objeto S3 hermano del tfstate — sin DynamoDB extra.

terraform {
  backend "s3" {
    bucket       = "tfstate-dkron-tunombre-2026" # ← cámbialo
    key          = "dkron/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # locking S3-native (Terraform >= 1.10)
  }
}