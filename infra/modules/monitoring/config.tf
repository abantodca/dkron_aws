# infra/modules/monitoring/config.tf
# Configuración versionada de Prometheus + Alertmanager — sube todos los YAML/JSON
# como parámetros SSM. Los config-init containers los bajan al EFS antes de arrancar.

resource "aws_ssm_parameter" "prometheus_yml" {
  name = "/${var.project}/prometheus/prometheus.yml"
  type = "String"
  tier = "Advanced"
  value = yamlencode({
    global = {
      scrape_interval     = "30s"
      evaluation_interval = "30s"
    }
    rule_files = ["/etc/prometheus/rules.yml"]
    alerting = {
      alertmanagers = [{ static_configs = [{ targets = ["localhost:9093"] }] }]
    }
    scrape_configs = [
      # Dkron vive en EC2 (no en ECS). Usamos file_sd_configs: Terraform
      # genera /etc/prometheus/targets/dkron.json con la IP privada actual
      # y Prometheus lo recarga automáticamente (file_sd refresh por defecto).
      {
        job_name        = "dkron"
        metrics_path    = "/metrics"
        file_sd_configs = [{ files = ["/etc/prometheus/targets/dkron.json"] }]
      },
      # node_exporter en la misma EC2 (puerto 9100) — CPU/RAM/disk del host
      {
        job_name        = "dkron-host"
        file_sd_configs = [{ files = ["/etc/prometheus/targets/dkron-host.json"] }]
      }
    ]
  })
}

# Targets por archivo. Terraform los regenera si cambia la IP privada de la EC2.
resource "aws_ssm_parameter" "prometheus_target_dkron" {
  name = "/${var.project}/prometheus/targets/dkron.json"
  type = "String"
  value = jsonencode([{
    targets = ["${var.ec2_private_ip}:8080"]
    labels  = { job = "dkron", role = "scheduler" }
  }])
}

resource "aws_ssm_parameter" "prometheus_target_host" {
  name = "/${var.project}/prometheus/targets/dkron-host.json"
  type = "String"
  value = jsonencode([{
    targets = ["${var.ec2_private_ip}:9100"]
    labels  = { job = "dkron-host", role = "node_exporter" }
  }])
}

resource "aws_ssm_parameter" "prometheus_rules" {
  name = "/${var.project}/prometheus/rules.yml"
  type = "String"
  value = yamlencode({
    groups = [{
      name = "dkron.rules"
      rules = [
        {
          alert       = "DkronHighFailureRate"
          expr        = "increase(dkron_failed_jobs_total[5m]) > 5"
          for         = "2m"
          labels      = { severity = "warning" }
          annotations = { summary = "Más de 5 jobs fallidos en 5 min" }
        },
        {
          alert       = "DkronNoJobsRunning"
          expr        = "max_over_time(dkron_running_jobs[1h]) < 1"
          for         = "10m"
          labels      = { severity = "critical" }
          annotations = { summary = "Scheduler sin actividad - posible caída" }
        },
        {
          alert       = "DkronTargetDown"
          expr        = "up{job=\"dkron\"} == 0"
          for         = "2m"
          labels      = { severity = "critical" }
          annotations = { summary = "Dkron no responde a Prometheus" }
        }
      ]
    }]
  })
}

resource "aws_ssm_parameter" "alertmanager_yml" {
  name = "/${var.project}/alertmanager/alertmanager.yml"
  type = "String"
  value = yamlencode({
    route = {
      receiver        = "sns"
      group_wait      = "30s"
      group_interval  = "5m"
      repeat_interval = "1h"
    }
    receivers = [{
      name = "sns"
      webhook_configs = [{
        url           = aws_lambda_function_url.alertmgr_to_sns.function_url
        send_resolved = true
      }]
    }]
  })
}
