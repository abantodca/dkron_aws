# infra/envs/prod/outputs.tf

output "vpc_id" { value = module.network.vpc_id }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "public_subnet_ids" { value = module.network.public_subnet_ids }

output "ecr_repository_url" { value = module.ecr.repository_url }

output "ec2_instance_id" { value = module.compute.ec2_instance_id }
output "ec2_private_ip" { value = module.compute.ec2_private_ip }
output "alb_dns_name" { value = module.compute.alb_dns_name }
output "app_sg_id" { value = module.compute.app_sg_id }

# Monitoring (PARTE 8)
output "grafana_url" { value = "http://${module.compute.alb_dns_name}:3000" }
output "ecs_cluster_name" { value = module.monitoring.ecs_cluster_name }
output "sns_topic_arn" { value = module.monitoring.sns_topic_arn }
output "lambda_function_url" { value = module.monitoring.lambda_function_url }
output "log_group_obs" { value = module.monitoring.log_group_obs }
