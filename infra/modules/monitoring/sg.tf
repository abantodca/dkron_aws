# infra/modules/monitoring/sg.tf

# ───── SG de la task Prometheus ─────
resource "aws_security_group" "prometheus" {
  name        = "${var.project}-prom-sg"
  description = "Prometheus task - scrapea EC2 y llama Lambda URL"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-prom-sg" }
}

# ───── SG de la task Grafana ─────
resource "aws_security_group" "grafana" {
  name        = "${var.project}-graf-sg"
  description = "Grafana task - recibe del ALB en 3000, consulta Prometheus"
  vpc_id      = var.vpc_id

  ingress {
    description = "ALB to Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # el ALB filtra; el SG-alb es restrictivo
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-graf-sg" }
}

# ───── Reglas cross-módulo: abrir 8080/9100 en el SG-app desde el SG-prom ─────
# Patrón: las reglas que cruzan módulos viven en aws_security_group_rule para
# evitar ciclos. Monitoring "extiende" el SG-app del módulo compute.
resource "aws_security_group_rule" "app_from_prom_8080" {
  type                     = "ingress"
  description              = "Prometheus scrape Dkron"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = var.app_security_group_id
  source_security_group_id = aws_security_group.prometheus.id
}

resource "aws_security_group_rule" "app_from_prom_9100" {
  type                     = "ingress"
  description              = "Prometheus scrape node_exporter"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = var.app_security_group_id
  source_security_group_id = aws_security_group.prometheus.id
}
