# infra/modules/network/variables.tf
variable "project" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" {
  type        = list(string)
  description = "Lista de AZs (necesitamos al menos 2 — ALB lo exige)."
  validation {
    condition     = length(var.azs) >= 2
    error_message = "El ALB requiere mínimo 2 AZs; este módulo crea 2 subnets por tipo."
  }
}