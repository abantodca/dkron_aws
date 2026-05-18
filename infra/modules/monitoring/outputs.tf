# infra/modules/monitoring/outputs.tf
output "ecs_cluster_name" { value = aws_ecs_cluster.obs.name }
output "prometheus_service_name" { value = aws_ecs_service.prometheus.name }
output "grafana_service_name" { value = aws_ecs_service.grafana.name }
output "grafana_target_group_arn" { value = aws_lb_target_group.grafana.arn }
output "sns_topic_arn" { value = aws_sns_topic.alerts.arn }
output "lambda_function_url" { value = aws_lambda_function_url.alertmgr_to_sns.function_url }
output "log_group_obs" { value = aws_cloudwatch_log_group.obs.name }
output "efs_id" { value = aws_efs_file_system.obs.id }
