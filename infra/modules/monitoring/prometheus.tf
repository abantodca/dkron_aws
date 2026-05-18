# infra/modules/monitoring/prometheus.tf

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.project}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn

  volume {
    name = "prom-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.obs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.prometheus.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "config-init"
      image     = "amazon/aws-cli:2.15.0"
      essential = false
      command = ["sh", "-c", <<-EOT
        set -e
        mkdir -p /etc/prometheus/targets /etc/alertmanager
        aws ssm get-parameter --name /${var.project}/prometheus/prometheus.yml             --query Parameter.Value --output text > /etc/prometheus/prometheus.yml
        aws ssm get-parameter --name /${var.project}/prometheus/rules.yml                  --query Parameter.Value --output text > /etc/prometheus/rules.yml
        aws ssm get-parameter --name /${var.project}/prometheus/targets/dkron.json         --query Parameter.Value --output text > /etc/prometheus/targets/dkron.json
        aws ssm get-parameter --name /${var.project}/prometheus/targets/dkron-host.json    --query Parameter.Value --output text > /etc/prometheus/targets/dkron-host.json
        aws ssm get-parameter --name /${var.project}/alertmanager/alertmanager.yml         --query Parameter.Value --output text > /etc/alertmanager/alertmanager.yml
      EOT
      ]
      mountPoints = [
        { sourceVolume = "prom-data", containerPath = "/etc/prometheus", readOnly = false },
        { sourceVolume = "prom-data", containerPath = "/etc/alertmanager", readOnly = false }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "prom-init"
        }
      }
    },
    {
      name      = "prometheus"
      image     = var.prometheus_image
      essential = true
      dependsOn = [{ containerName = "config-init", condition = "SUCCESS" }]
      portMappings = [{
        containerPort = 9090
        protocol      = "tcp"
      }]
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
        "--storage.tsdb.retention.time=15d",
        "--web.enable-lifecycle"
      ]
      mountPoints = [
        { sourceVolume = "prom-data", containerPath = "/prometheus", readOnly = false },
        { sourceVolume = "prom-data", containerPath = "/etc/prometheus", readOnly = false }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "prometheus"
        }
      }
    },
    {
      name      = "alertmanager"
      image     = var.alertmanager_image
      essential = true
      dependsOn = [{ containerName = "config-init", condition = "SUCCESS" }]
      portMappings = [{
        containerPort = 9093
        protocol      = "tcp"
      }]
      command = ["--config.file=/etc/alertmanager/alertmanager.yml"]
      mountPoints = [
        { sourceVolume = "prom-data", containerPath = "/etc/alertmanager", readOnly = false }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.obs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "alertmanager"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "prometheus" {
  name            = "prometheus"
  cluster         = aws_ecs_cluster.obs.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.prometheus.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.prometheus.arn
  }

  depends_on = [aws_efs_mount_target.obs]
}
