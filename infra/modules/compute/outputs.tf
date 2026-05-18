# infra/modules/compute/outputs.tf
output "ec2_instance_id" { value = aws_instance.dkron.id }
output "ec2_private_ip" { value = aws_instance.dkron.private_ip }
output "alb_dns_name" { value = aws_lb.this.dns_name }
output "alb_arn" { value = aws_lb.this.arn } # consumido por module.monitoring (8.2)
output "alb_listener_arn" { value = aws_lb_listener.http.arn }
output "app_sg_id" { value = aws_security_group.app.id }
output "alb_sg_id" { value = aws_security_group.alb.id }
output "log_group_dkron" { value = aws_cloudwatch_log_group.dkron.name }
output "log_group_compose" { value = aws_cloudwatch_log_group.compose.name }
output "ec2_role_name" { value = aws_iam_role.ec2.name }
output "ansible_ssm_bucket" { value = aws_s3_bucket.ansible_ssm.id }