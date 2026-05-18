# infra/modules/monitoring/cluster.tf

# ───── ECS cluster Fargate para Prom/Graf ─────
resource "aws_ecs_cluster" "obs" {
  name = "${var.project}-obs"
  setting {
    name  = "containerInsights"
    value = "disabled" # ahorra costo
  }
}

resource "aws_ecs_cluster_capacity_providers" "obs" {
  cluster_name       = aws_ecs_cluster.obs.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

# ───── Cloud Map: DNS privado para que Grafana le hable a Prometheus ─────
resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "${var.project}.local"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "prometheus" {
  name = "prometheus"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# ───── Log group compartido para Prom/Alertmgr/Grafana ─────
resource "aws_cloudwatch_log_group" "obs" {
  name              = "/${var.project}/ecs/obs"
  retention_in_days = 1
}

# ───── Password admin de Grafana en SSM SecureString ─────
resource "aws_ssm_parameter" "grafana_admin_password" {
  name  = "/${var.project}/${var.environment}/grafana/admin_password"
  type  = "SecureString"
  value = var.grafana_admin_password
  tags  = { Name = "${var.project}-graf-pass" }
}
