locals {
  services = {
    accountservice = {
      container_port    = 5001,
      alb_port          = 5001,
      target_group_port = 5001
    },
    inventoryservice = {
      container_port    = 5002,
      alb_port          = 5002,
      target_group_port = 5002
    },
    shippingservice = {
      container_port    = 5003,
      alb_port          = 5003,
      target_group_port = 5003
    }
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "ecs-services-logs"
}

resource "aws_ecs_cluster" "nova_cluster" {
  name = "nova-cluster"
}

resource "aws_ecs_task_definition" "nova-tasks-def" {
  for_each                 = local.services
  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions = jsonencode([{
    name      = each.key
    image     = "${aws_ecr_repository.nova-ecrs[each.key].repository_url}:latest"
    cpu       = 128
    memory    = 256
    essential = true
    portMappings = [{
      containerPort = each.value.container_port

    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "REDIS_ENDPOINT"
        value = aws_elasticache_cluster.nova_redis.configuration_endpoint
      }
    ]

  }])
}

resource "aws_ecs_service" "nova-services" {
  for_each        = local.services
  name            = each.key
  cluster         = aws_ecs_cluster.nova_cluster.id
  task_definition = aws_ecs_task_definition.nova-tasks-def[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_service_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nova-tgs[each.key].arn
    container_name   = each.key
    container_port   = each.value.alb_port
  }
}

