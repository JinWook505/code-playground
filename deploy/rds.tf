# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnet.public[*].id

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}

# RDS Instance (Free Tier friendly)
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"

  engine         = "postgres"
  engine_version = "15.18" # 해당 리전에서 사용 가능한 15 계열 최신 마이너
  instance_class = var.rds_instance_class # 프리 티어: db.t3.micro / db.t4g.micro

  # 프리 티어 스토리지 무료 한도는 20GB. var 값이 20 이하인지 확인하세요.
  # 자동 확장(max_allocated_storage)은 20GB 초과분에 과금되므로 제거했습니다.
  allocated_storage = var.rds_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  # 프리 티어에서는 백업 보존 기간에 제한이 있어 0으로 비활성화.
  # backup_retention_period = 0 이면 backup_window 는 불필요하므로 제거.
  backup_retention_period = 0
  maintenance_window      = "sun:04:00-sun:05:00"

  # 과금/제약 유발 가능 옵션을 명시적으로 비활성화
  multi_az                     = false
  performance_insights_enabled = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
  }
}
