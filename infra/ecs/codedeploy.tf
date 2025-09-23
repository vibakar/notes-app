resource "aws_codedeploy_app" "ecs" {
  name             = "notes-app-frontend"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "frontend" {
  app_name               = aws_codedeploy_app.ecs.name
  deployment_group_name  = "frontend-bluegreen-dg"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  # deployment_config_name = "CodeDeployDefault.ECSLinear10PercentEvery1Minute"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.notes_app.name
    service_name = aws_ecs_service.frontend.name
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.frontend_blue_tg.name
      }

      target_group {
        name = aws_lb_target_group.frontend_green_tg.name
      }

      prod_traffic_route {
        listener_arns = [aws_lb_listener.frontend_blue.arn]
      }

      # test_traffic_route {
      #   listener_arns = [aws_lb_listener.frontend_green.arn]
      # }
    }
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 60
    }

    deployment_ready_option {
      # action_on_timeout = "CONTINUE_DEPLOYMENT"
      # wait_time_in_minutes = 0
      action_on_timeout = "STOP_DEPLOYMENT" # <-- This pauses traffic shift
      wait_time_in_minutes = 60             # <-- Optional: max wait before timeout
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
