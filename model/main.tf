provider "aws" {
  region     = "ap-northeast-1"
  access_key = "AKIA2C2TL65XXXXX"
  secret_key = "soNz77mvnSCIQjdJAESPEOn0XXXXXX"
}

locals {
  container_name = "cnbateblogweb"
  name           = "cnbateblogwebCluster"
  service_name   = "cnbateblogwebservice"
  http_port      = ["80"]
  cidr_block     = "10.255.0.0/16"
  container_port = tonumber(module.alb.alb_target_group_blue_port)
}

module "securitygroup" {
  source                 = "../modules/securitygroup"
  enabled_security_group = true
  security_group_name    = "cnbateblogwebCluster_ecs_securitygroup"
  security_group_vpc_id  = module.vpc.vpc_id

  from_port_ingress = 9021
  to_port_ingress   = 9021

  from_port_egress = 0
  to_port_egress   = 0
}

# module "codedeploy" {
#   source                     = "../modules/codedeploy"
#   name                       = "example-deploy"
#   ecs_cluster_name           = local.name
#   ecs_service_name           = local.service_name
#   lb_listener_arns           = [module.alb.http_alb_listener_blue_arn]
#   blue_lb_target_group_name  = module.alb.aws_lb_target_group_blue_name
#   green_lb_target_group_name = module.alb.aws_lb_target_group_green_name

#   auto_rollback_enabled            = true
#   auto_rollback_events             = ["DEPLOYMENT_FAILURE"]
#   action_on_timeout                = "STOP_DEPLOYMENT"
#   wait_time_in_minutes             = 1440
#   termination_wait_time_in_minutes = 1440
#   test_traffic_route_listener_arns = []
#   iam_path                         = "/service-role/"
#   description                      = "This is example"

#   tags = {
#     Environment = "prod"
#   }
# }

module "ecs_fargate" {
  source           = "../modules/ecs"
  name             = local.name
  service_name     = local.service_name
  container_name   = local.container_name
  container_port   = local.container_port
  subnets          = module.vpc.public_subnet_ids
  security_groups  = [module.securitygroup.security_group_id]
  target_group_arn = module.alb.alb_target_group_blue_arn
  vpc_id           = module.vpc.vpc_id

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = "693275195242.dkr.ecr.ap-northeast-1.amazonaws.com/cnbateblogweb:28" #"693275195242.dkr.ecr.ap-northeast-1.amazonaws.com/cnbateblogweb:28" #"docker.io/yunqian44/cnbateblogweb:laster"
      essential = true
      environment = [
        { name : "Location", value : "Singapore" },
        { name : "ASPNETCORE_ENVIRONMENT", value : "Production" }
      ]
      portMappings = [
        {
          containerPort = local.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])

  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  deployment_controller_type         = "ECS"
  assign_public_ip                   = true
  health_check_grace_period_seconds  = 10
  platform_version                   = "LATEST"
  cpu                                = 256
  memory                             = 512
  requires_compatibilities           = ["FARGATE"]
  iam_path                           = "/service_role/"
  description                        = "This is example"
  enabled                            = true

  ecs_task_execution_role_arn = aws_iam_role.default.arn

  tags = {
    Environment = "prod"
  }
}

resource "aws_iam_role" "default" {
  name               = "iam-rol-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_task_execution" {
  name   = aws_iam_role.default.name
  policy = data.aws_iam_policy.ecs_task_execution.policy
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}

module "alb" {
  source                     = "../modules/elb"
  name                       = "elb-cnbateblogweb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnet_ids
  enable_https_listener      = false
  enable_http_listener       = true
  enable_deletion_protection = false

  enabled_lb_target_group_blue   = true
  aws_lb_target_group_blue_name  = "elb-cnbateblogweb-blue"
  health_check_path              = ""
  enabled_lb_target_group_green  = true
  aws_lb_target_group_green_name = "elb-cnbateblogweb-green"

  enable_http_listener_blue      = true
  http_port_blue                 = 80
  target_group_blue_port         = 9021
  enable_http_listener_rule_blue = true


  enable_http_listener_green      = true
  http_port_green                 = 8080
  target_group_green_port         = 8080
  enable_http_listener_rule_green = true
}

module "vpc" {
  source                    = "../modules/vpc"
  cidr_block                = local.cidr_block
  name                      = "ecs-fargate"
  public_subnet_cidr_blocks = [cidrsubnet(local.cidr_block, 2, 0), cidrsubnet(local.cidr_block, 2, 1)]
  public_availability_zones = data.aws_availability_zones.available.names
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

