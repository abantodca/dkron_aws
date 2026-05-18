# infra/envs/prod/variables.tf
# Declaraciones — los valores van en terraform.tfvars

variable "region" {
  type    = string
  default = "us-east-1"
}
variable "project" {
  type    = string
  default = "dkron"
}
variable "environment" {
  type    = string
  default = "prod"
}
variable "owner" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "CIDR del VPC. /16 deja espacio para crecer; subnets /24 (256 IPs cada una)."
}

variable "azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "AZs para subnets. ALB requiere mín. 2; resto es single-AZ por costo."
}

variable "dkron_image_tag" {
  type        = string
  default     = "v4.0.9"
  description = "Tag de la imagen Dkron a usar (pinneada, NUNCA :latest). Lo consume Ansible vía --extra-vars; Terraform lo declara para que aparezca en terraform.tfvars como única fuente de verdad del proyecto."
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Free tier 12 meses. Si Dkron hace OOM sube a t3.small (~$15/mes)."
}

variable "ssh_public_key" {
  type        = string
  description = "Contenido de ~/.ssh/id_ed25519.pub (Terraform crea key pair, deploy real vía SSM)."
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDRs autorizados a SSH 22 en la EC2. Vacío = SSH cerrado (usa SSM)."
}

variable "github_repo" {
  type        = string
  description = "GitHub repo (owner/repo). Lo consume bootstrap-oidc.sh y se referencia en el CI vía $${github.repository}. Si NO usas el módulo cicd opcional, esta var queda declarada pero sin uso en Terraform — es OK, sirve para documentar la dependencia en un solo lugar."
}

variable "alert_email" {
  type        = string
  description = "Email destino del topic SNS de alertas Prometheus."
}

variable "grafana_admin_password" {
  type        = string
  sensitive   = true
  description = "Password admin de Grafana. Lo consume Ansible vía --extra-vars; Terraform lo declara para mantener una única fuente de verdad en terraform.tfvars."
}