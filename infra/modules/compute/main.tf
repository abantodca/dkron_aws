# infra/modules/compute/main.tf

# ───── Security Groups ─────
resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "ALB publico - acepta HTTP/3000 de Internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP (Dkron UI/API)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana (PARTE 8)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-alb-sg" }
}

resource "aws_security_group" "app" {
  name        = "${var.project}-app-sg"
  description = "EC2 con Dkron - solo recibe del ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Dkron HTTP desde ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH solo si hay CIDRs explícitos (debug puntual)
  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []
    content {
      description = "SSH debug"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-app-sg" }
}

# ───── Key Pair + AMI ─────
resource "aws_key_pair" "this" {
  key_name   = "${var.project}-key"
  public_key = var.ssh_public_key
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ───── IAM: instance profile ─────
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.project}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# Pull desde ECR (la EC2 hace docker pull al desplegar)
resource "aws_iam_role_policy" "ec2_ecr" {
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = var.ecr_repository_arn
      }
    ]
  })
}

# Lectura del parámetro SSM con la URL del repo ECR
# (Ansible lo resuelve en runtime — ver group_vars/all.yml lookup '/dkron/prod/image_repo').
resource "aws_iam_role_policy" "ec2_ssm_read" {
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters"]
      Resource = [var.image_repo_param_arn]
    }]
  })
}

# Bucket auxiliar para el plugin community.aws.aws_ssm (transferencia de archivos
# Ansible → EC2 vía SSM). NO confundir con el bucket de outputs de jobs.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "ansible_ssm" {
  bucket        = "${var.project}-ansible-ssm-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = { Name = "${var.project}-ansible-ssm" }
}

resource "aws_s3_bucket_public_access_block" "ansible_ssm" {
  bucket                  = aws_s3_bucket.ansible_ssm.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# La EC2 lee/escribe en el bucket ansible-ssm (el plugin sube payloads transitorios)
resource "aws_iam_role_policy" "ec2_ansible_ssm" {
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.ansible_ssm.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = aws_s3_bucket.ansible_ssm.arn
      }
    ]
  })
}

# Publica el nombre del bucket en SSM para que el inventario aws_ec2.yml lo resuelva
# en runtime (mismo patrón que /dkron/prod/image_repo).
resource "aws_ssm_parameter" "ansible_ssm_bucket" {
  name  = "/${var.project}/${var.environment}/ansible_ssm_bucket"
  type  = "String"
  value = aws_s3_bucket.ansible_ssm.id
  tags  = { Name = "${var.project}-ansible-ssm-bucket" }
}

# CloudWatch Logs agent
resource "aws_iam_role_policy_attachment" "ec2_cw" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM Session Manager (login sin SSH para debug y conexión Ansible)
resource "aws_iam_role_policy_attachment" "ec2_ssm_managed" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# ───── CloudWatch Log Groups ─────
resource "aws_cloudwatch_log_group" "dkron" {
  name              = "/${var.project}/ec2/dkron"
  retention_in_days = 1 # alcance proyecto; prod real: 7-30
}

resource "aws_cloudwatch_log_group" "compose" {
  name              = "/${var.project}/ec2/compose"
  retention_in_days = 1
}

# ───── EC2 (host de Dkron) ─────
resource "aws_instance" "dkron" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = false
  monitoring                  = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # user_data MÍNIMO: solo SSM agent + Python.
  # Docker, compose y Dkron los instala Ansible (PARTE 6) — idempotente, repetible.
  user_data = <<-EOT
    #!/bin/bash
    set -e
    dnf -y update
    dnf -y install python3 awscli
    systemctl enable --now amazon-ssm-agent
  EOT

  tags = {
    Name = "${var.project}-host"
    Role = "dkron-server"
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [ami] # no rotemos AMI en cada apply
  }
}

# ───── ALB ─────
resource "aws_lb" "this" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "${var.project}-alb" }
}

resource "aws_lb_target_group" "dkron" {
  name        = "${var.project}-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/v1/jobs"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "dkron" {
  target_group_arn = aws_lb_target_group.dkron.arn
  target_id        = aws_instance.dkron.id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dkron.arn
  }
}