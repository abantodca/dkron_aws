# infra/modules/compute/variables.tf
variable "project" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "ssh_public_key" { type = string }
variable "ssh_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "ecr_repository_arn" { type = string }
variable "image_repo_param_arn" {
  type        = string
  description = "ARN del SSM String /dkron/prod/image_repo — Ansible lo lee para saber qué tag de ECR usar."
}