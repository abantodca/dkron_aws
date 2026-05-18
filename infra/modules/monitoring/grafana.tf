# infra/modules/monitoring/grafana.tf

resource "aws_ssm_parameter" "grafana_datasource" {
  name = "/${var.project}/grafana/datasource.yml"
  type = "SecureString"
  value = yamlencode({
    apiVersion = 1
    datasources = [{
      name      = "Prometheus"
      type      = "prometheus"
      access    = "proxy"
      url       = "http://prometheus.${var.project}.local:9090"
      isDefault = true
    }]
  })
}

resource "aws_ssm_parameter" "grafana_dashboard" {
  name  = "/${var.project}/grafana/dashboard.json"
  type  = "SecureString"
  tier  = "Advanced"
  value = file("${path.module}/dashboards/dkron-red.json")
}

# Provider que le dice a Grafana DÓNDE buscar dashboards .json al arrancar.
resource "aws_ssm_parameter" "grafana_dashboard_provider" {
  name = "/${var.project}/grafana/dashboard_provider.yml"
  type = "SecureString"
  value = yamlencode({
    apiVersion = 1
    providers = [{
      name            = "dkron"
      folder          = "Dkron"
      type            = "file"
      disableDeletion = true
      options         = { path = "/var/lib/grafana/dashboards" }
    }]
  })
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # Grafana 11.2 recomienda mínimo 1 GB. Con 512 MB hacía OOM kill silencioso
  # durante el boot (sqlite migrate + plugin scan), causando loop initial->drain.
  # 2 GB da margen para plugins + dashboards sin tocar swap.
  cpu    = "512"
  memory = "2048"

  execution_role_arn = aws_iam_role.exec.arn
  task_role_arn      = aws_iam_role.task.arn

  volume {
    name = "graf-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.obs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.grafana.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    # Init container: baja datasource + dashboard + provider de SSM al EFS
    # ANTES de que arranque Grafana. Sin esto, Grafana arranca vacío.
    {
      name      = "config-init"
      image     = "amazon/aws-cli:2.15.0"
      essential = false
      # ENTRYPOINT del Dockerfile es ["aws"]; lo sustituimos para poder ejecutar sh.
      entryPoint = ["/bin/sh", "-c"]
      command = [<<-EOT
        set -e
        mkdir -p /var/lib/grafana/provisioning/datasources
        mkdir -p /var/lib/grafana/provisioning/dashboards
        mkdir -p /var/lib/grafana/dashboards
        aws ssm get-parameter --name /${var.project}/grafana/datasource.yml          --query Parameter.Value --output text > /var/lib/grafana/provisioning/datasources/prometheus.yml
        aws ssm get-parameter --name /${var.project}/grafana/dashboard_provider.yml  --query Parameter.Value --output text > /var/lib/grafana/provisioning/dashboards/dkron.yml
        aws ssm get-parameter --name /${var.project}/grafana/dashboard.json          --query Parameter.Value --output text > /var/lib/grafana/dashboards/dkron-red.json
        # Grafana corre como uid 472 - el access point EFS ya pone owner 472:472, forzamos por si acaso
        chown -R 472:472 /var/lib/grafana/provisioning /var/lib/grafana/dashboards || true
      EOT
      ]
      mountPoints = [{
        sourceVolume  = "graf-data"
        containerPath = "/var/lib/grafana"
        readOnly      = false
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "grafana-init"
        }
      }
    },
    {
      name      = "grafana"
      image     = var.grafana_image
      essential = true
      dependsOn = [{ containerName = "config-init", condition = "SUCCESS" }]
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = "admin" },
        { name = "GF_USERS_ALLOW_SIGN_UP", value = "false" },
        { name = "GF_AUTH_ANONYMOUS_ENABLED", value = "false" },
        # Path por defecto es /etc/grafana/provisioning; lo movemos al EFS
        { name = "GF_PATHS_PROVISIONING", value = "/var/lib/grafana/provisioning" }
      ]
      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD"
          valueFrom = aws_ssm_parameter.grafana_admin_password.arn
        }
      ]
      mountPoints = [{
        sourceVolume  = "graf-data"
        containerPath = "/var/lib/grafana"
        readOnly      = false
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])
}

resource "aws_lb_target_group" "grafana" {
  name        = "${var.project}-grafana"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip" # Fargate awsvpc
  vpc_id      = var.vpc_id
  health_check {
    path    = "/api/health"
    matcher = "200"
  }
}

# Listener adicional en el ALB existente para Grafana en puerto 3000
resource "aws_lb_listener" "grafana" {
  load_balancer_arn = var.alb_arn
  port              = 3000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = aws_ecs_cluster.obs.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Grafana tarda ~30-45s en arrancar (sqlite migrations, plugin scan). Sin
  # gracia, el ALB marca unhealthy antes del primer 200 y ECS recicla el task.
  health_check_grace_period_seconds = 90

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.grafana.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.grafana, aws_efs_mount_target.obs]
}
