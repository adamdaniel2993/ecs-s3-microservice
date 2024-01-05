resource "aws_elasticache_subnet_group" "nova-redis-subnet-group" {
  name       = "nova-redis-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_cluster" "nova_redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.nova-redis-subnet-group.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  availability_zone    = "us-east-1a"
}

