resource "random_password" "database_password" {
  length           = 32
  special          = true
  override_special = "!#-_=+"
}

resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group-${var.env}"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Name        = "${var.env}-rds-subnet-group"
    Environment = var.env
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg-${var.env}"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-rds-sg"
    Environment = var.env
  }
}

# primary RDS PostgreSQL instance
resource "aws_db_instance" "primary" {
  identifier             = "${var.env}-postgresql-primary"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.database_password.result
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az                     = false
  publicly_accessible          = false
  skip_final_snapshot          = true
  deletion_protection          = false
  backup_retention_period      = 0
  performance_insights_enabled = false
  apply_immediately            = true

  tags = {
    Name        = "${var.env}-postgresql-primary"
    Environment = var.env
  }

  depends_on = [aws_db_subnet_group.rds, aws_security_group.rds]
}

# read replica — disabled by default (adds cost); set enable_rds_replica=true to enable
resource "aws_db_instance" "read_replica" {
  count                  = var.enable_rds_replica ? 1 : 0
  identifier             = "${var.env}-postgresql-replica-0"
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  replicate_source_db    = aws_db_instance.primary[0].identifier
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  skip_final_snapshot    = true
  apply_immediately      = true
  tags                   = { Name = "${var.env}-postgresql-replica-0" }
}

# stores RDS connection details — synced to K8s by ESO
resource "aws_secretsmanager_secret" "rds_connection" {
  name                    = "rds/connection/${var.env}"
  description             = "RDS connection details for ${var.env}"
  recovery_window_in_days = 0

  tags = {
    Name        = "rds-connection-secret-${var.env}"
    Environment = var.env
  }
}

resource "aws_secretsmanager_secret_version" "rds_connection" {
  secret_id = aws_secretsmanager_secret.rds_connection.id
  secret_string = jsonencode({
    username          = aws_db_instance.primary.username
    password          = random_password.database_password.result
    database          = aws_db_instance.primary.db_name
    endpoint          = aws_db_instance.primary.endpoint
    connection_string = "postgres://${aws_db_instance.primary.username}:${random_password.database_password.result}@${aws_db_instance.primary.endpoint}/${aws_db_instance.primary.db_name}"
  })

  depends_on = [aws_db_instance.primary]
}
