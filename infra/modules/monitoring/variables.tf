# infra/modules/monitoring/variables.tf
variable "project" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

# Inputs desde otros módulos
variable "alb_arn" {
  type        = string
  description = "ARN del ALB existente (módulo compute). Le añadimos listener :3000 para Grafana."
}
variable "ec2_private_ip" {
  type        = string
  description = "IP privada de la EC2 con Dkron — Prometheus la usa en file_sd_configs."
}
variable "app_security_group_id" {
  type        = string
  description = "SG de la EC2 con Dkron. Aquí abrimos 8080/9100 desde el SG de Prometheus."
}

# Configuración propia del módulo
variable "alert_email" {
  type        = string
  description = "Email destino del topic SNS de alertas."
}
variable "grafana_admin_password" {
  type        = string
  sensitive   = true
  description = "Password del usuario admin de Grafana. Se guarda en SSM SecureString."
}
variable "prometheus_image" {
  type    = string
  default = "prom/prometheus:v2.54.1"
}
variable "alertmanager_image" {
  type    = string
  default = "prom/alertmanager:v0.27.0"
}
variable "grafana_image" {
  type    = string
  default = "grafana/grafana:11.2.0"
}
