resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-group-${var.env}"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Name        = "${var.env}-redis-subnet-group"
    Environment = var.env
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg-${var.env}"
  description = "Allow Redis access from EKS nodes"
  vpc_id      = data.aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
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
    Name        = "${var.env}-redis-sg"
    Environment = var.env
  }
}

# single-node Redis cluster — sufficient for study environment
resource "aws_elasticache_cluster" "redis" {
  count                = var.redis_single_node_cluster
  cluster_id           = "${var.project_name}-redis-${var.env}"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_nodes
  parameter_group_name = var.redis_parameter_group_name
  engine_version       = var.redis_engine_version
  apply_immediately    = var.redis_apply_immediately
  port                 = var.redis_port
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  tags = {
    Name        = "${var.env}-redis"
    Environment = var.env
  }

  depends_on = [aws_elasticache_subnet_group.redis, aws_security_group.redis]
}

# replication group — commented out for study environment (adds cost, needs multi-node)
# resource "aws_elasticache_replication_group" "redis" {
#   count                      = var.redis_replication_group
#   replication_group_id       = "${var.project_name}-redis-replica-${var.env}"
#   description                = "Redis replication group for ${var.project_name} ${var.env}"
#   engine                     = var.redis_engine
#   engine_version             = var.redis_engine_version
#   node_type                  = var.redis_node_type
#   port                       = var.redis_port
#   parameter_group_name       = var.redis_parameter_group_name
#   apply_immediately          = var.redis_apply_immediately
#   subnet_group_name          = aws_elasticache_subnet_group.redis.name
#   security_group_ids         = [aws_security_group.redis.id]
#   multi_az_enabled           = var.multi_az_enabled
#   automatic_failover_enabled = var.automatic_failover_enabled
#   num_cache_clusters         = var.num_cache_clusters
#   at_rest_encryption_enabled = var.redis_at_rest_encryption_enabled
#   transit_encryption_enabled = var.redis_transit_encryption_enabled
#   snapshot_retention_limit   = var.redis_snapshot_retention_limit
#   snapshot_window            = var.redis_snapshot_window
#   maintenance_window         = var.redis_maintenance_window
#   auto_minor_version_upgrade = var.redis_auto_minor_version_upgrade
# }
