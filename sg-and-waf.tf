resource "aws_security_group" "alb_sg" {
  name        = "nova-alb-sg"
  description = "Security Group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Service Security Group
resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs_service_sg"
  description = "Security Group for ECS Services"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 5002
    to_port         = 5002
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 5003
    to_port         = 5003
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#db sg

resource "aws_security_group" "nova_rds_sg" {
  name        = "nova-rds-sg"
  description = "Security Group for RDS MySQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### Redis SG

resource "aws_security_group" "redis_sg" {
  name        = "nova_redis_sg"
  description = "Security group for redis"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id]
  }
}

########################################################################################

resource "aws_wafv2_web_acl" "nova-waf" {
  name        = "nova-waf"
  description = "Example WAF for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "BlockIPExample"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.nova-ip-set.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "test-metric"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Environment = "novaexam"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "test-acl-metric"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_ip_set" "nova-ip-set" {
  name               = "nova-cloudfront-ipset"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["1.2.3.4/32"]
}

#resource "aws_wafv2_web_acl_association" "nova-waf-webacl-association" {
#  resource_arn = aws_cloudfront_distribution.s3_distribution.arn
#  web_acl_arn  = aws_wafv2_web_acl.nova-waf.arn
#}
