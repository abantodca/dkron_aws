# infra/modules/ecr/outputs.tf
output "repository_url" { value = aws_ecr_repository.this.repository_url }
output "repository_arn" { value = aws_ecr_repository.this.arn }
output "repository_name" { value = aws_ecr_repository.this.name }
output "image_repo_param_arn" { value = aws_ssm_parameter.image_repo.arn }
output "image_repo_param_name" { value = aws_ssm_parameter.image_repo.name }