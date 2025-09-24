resource "aws_ecs_cluster" "notes_app" {
  name = "notes-app-cluster"
}

resource "aws_ecs_task_definition" "database" {
  family                   = "database"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name         = "postgres"
    image        = "postgres:latest"
    portMappings = [{
      containerPort = 5432
    }]
    environment = local.database_env
  }])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name         = "backend"
    image        = var.backend_image
    portMappings = [{
      containerPort = 3000
    }]
    environment = local.backend_env
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "backend"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name         = "frontend"
    image        = var.frontend_image
    portMappings = [{
      containerPort = 80
    }]
    environment = local.frontend_env
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
        awslogs-region        = "eu-west-2"
        awslogs-stream-prefix = "frontend"
      }
    }
  }])
}

resource "aws_security_group" "alb_sg" {
  name        = "notes-app-alb-sg"
  description = "Allow inbound HTTP to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "notes-app-ecs-sg"
  description = "Allow traffic from ALB and internal DB traffic"
  vpc_id      = module.vpc.vpc_id

  # Allow HTTP traffic from ALB SG to frontend (port 80)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow backend traffic from ALB SG (port 3000)
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow Postgres traffic internally from private subnets (backend)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_alb" {
  name               = "notes-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "frontend_blue_tg" {
  name     = "frontend-blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    unhealthy_threshold = 2
    healthy_threshold   = 5
    timeout             = 5
  }

  target_type = "ip"
}

resource "aws_lb_target_group" "frontend_green_tg" {
  name     = "frontend-green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    unhealthy_threshold = 2
    healthy_threshold   = 5
    timeout             = 5
  }

  target_type = "ip"
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/api/v1/health"
    matcher             = "200"
    interval            = 30
    unhealthy_threshold = 2
    healthy_threshold   = 5
    timeout             = 5
  }

  target_type = "ip"
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Invalid host header or no matching rule."
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "notes_app_prod_rule" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_blue_tg.arn
  }

  condition {
    host_header {
      values = ["notes-app.vibakar.com"]
    }
  }
}

resource "aws_lb_listener_rule" "notes_app_preview_rule" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_green_tg.arn
  }

  condition {
    host_header {
      values = ["preview-notes-app.vibakar.com"]
    }
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.notes_app.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_blue_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }

  propagate_tags = "SERVICE"

  depends_on = [aws_lb_listener.frontend]
}

resource "aws_ecs_service" "backend" {
  name            = "backend"
  cluster         = aws_ecs_cluster.notes_app.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "backend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.backend, aws_ecs_service.database]
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "database.local"
  description = "Service discovery for internal ECS services"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "database" {
  name = "postgres"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      type = "A"
      ttl  = 10
    }

    routing_policy = "MULTIVALUE"
  }
}

resource "aws_ecs_service" "database" {
  name            = "postgres"
  cluster         = aws_ecs_cluster.notes_app.id
  task_definition = aws_ecs_task_definition.database.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.database.arn
  }
}

resource "aws_route53_record" "alb_cname" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "notes-app.vibakar.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.app_alb.dns_name]
}

resource "aws_route53_record" "preview_alb_cname" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "preview-notes-app.vibakar.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.app_alb.dns_name]
}

data "aws_route53_zone" "primary" {
  name         = "vibakar.com"
  private_zone = false
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/notes-app"
  retention_in_days = 7

  tags = {
    Environment = "prod"
    Application = "notes-app"
  }
}
