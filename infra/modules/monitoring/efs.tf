# infra/modules/monitoring/efs.tf

resource "aws_efs_file_system" "obs" {
  creation_token = "${var.project}-obs"
  encrypted      = true
  tags           = { Name = "${var.project}-obs" }
}

resource "aws_efs_mount_target" "obs" {
  for_each        = toset(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.obs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "prometheus" {
  file_system_id = aws_efs_file_system.obs.id
  posix_user {
    uid = 65534
    gid = 65534
  }
  root_directory {
    path = "/prometheus"
    creation_info {
      owner_uid   = 65534
      owner_gid   = 65534
      permissions = "0755"
    }
  }
}

resource "aws_efs_access_point" "grafana" {
  file_system_id = aws_efs_file_system.obs.id
  posix_user {
    uid = 472
    gid = 472
  }
  root_directory {
    path = "/grafana"
    creation_info {
      owner_uid   = 472
      owner_gid   = 472
      permissions = "0755"
    }
  }
}

resource "aws_security_group" "efs" {
  name        = "${var.project}-efs"
  description = "EFS mount targets - NFS 2049 desde tasks Prom/Graf"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS desde tasks Prom/Graf"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus.id, aws_security_group.grafana.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project}-efs" }
}
