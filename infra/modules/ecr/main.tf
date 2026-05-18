# infra/modules/ecr/main.tf

resource "aws_ecr_repository" "this" {
  name                 = "${var.project}-${var.name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Lifecycle: no acumular basura indefinidamente (cuesta storage)
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Mantener últimas 5 imágenes con tag"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "imageCountMoreThan"
          countNumber    = 5
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Borrar imágenes sin tag tras 1 día"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      }
    ]
  })
}

# Publica la URL del repositorio en SSM para que Ansible la lea en runtime
# (lookup amazon.aws.aws_ssm '/dkron/prod/image_repo' en ansible/inventories/prod/group_vars/all.yml).
resource "aws_ssm_parameter" "image_repo" {
  name  = "/${var.project}/prod/image_repo"
  type  = "String"
  value = aws_ecr_repository.this.repository_url
  tags  = { Name = "${var.project}-image-repo" }
}