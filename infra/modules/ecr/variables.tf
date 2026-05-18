# infra/modules/ecr/variables.tf
variable "project" { type = string }
variable "name" {
  type        = string
  default     = "dkron"
  description = "Nombre del repositorio ECR (sufijo)."
}