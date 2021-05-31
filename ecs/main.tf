resource "aws_ecs_cluster" "example" {
  name = var.name
}

resource "aws_ecs_service" "default" {
  #count = var.enabled && length(var.service_name) > 0 ? length(var.service_name) : 0
  count = var.enabled ? 1 : 0

  # The name of your service. Up to 255 letters (uppercase and lowercase), numbers, hyphens, and underscores are allowed.
  # Service names must be unique within a cluster, but you can have similarly named servicesy
  # in multiple clusters within a region or across multiple regions.
  name = var.service_name

  # The family and revision (family:revision) or full ARN of the task definition to run in your service.
  # If a revision is not specified, the latest ACTIVE revision is used.
  task_definition = aws_ecs_task_definition.default[0].arn

  # The short name or full Amazon Resource Name (ARN) of the cluster on which to run your service.
  # If you do not specify a cluster, the default cluster is assumed.
  cluster = aws_ecs_cluster.example.arn

  # The number of instantiations of the specified task definition to place and keep running on your cluster.
  desired_count = var.desired_count

  # The maximumPercent parameter represents an upper limit on the number of your service's tasks
  # that are allowed in the RUNNING or PENDING state during a deployment,
  # as a percentage of the desiredCount (rounded down to the nearest integer).
  deployment_maximum_percent = var.deployment_maximum_percent

  # The minimumHealthyPercent represents a lower limit on the number of your service's tasks
  # that must remain in the RUNNING state during a deployment,
  # as a percentage of the desiredCount (rounded up to the nearest integer).
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  deployment_controller {
    # The deployment controller type to use. Valid values: CODE_DEPLOY, ECS.
    type = var.deployment_controller_type
  }

  # The network configuration for the service. This parameter is required for task definitions
  # that use the awsvpc network mode to receive their own Elastic Network Interface.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html
  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups

    # Whether the task's elastic network interface receives a public IP address.
    assign_public_ip = var.assign_public_ip
  }

  # Note: As a result of an AWS limitation, a single load_balancer can be attached to the ECS service at most.
  #
  # When you create any target groups for these services, you must choose ip as the target type, not instance.
  # This is because tasks that use the awsvpc network mode are associated with an elastic network interface, not an EC2 instance.
  #
  # After you create a service, the load balancer name or target group ARN, container name,
  # and container port specified in the service definition are immutable.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-load-balancing.html#load-balancing-concepts
  load_balancer {
    # The ARN of the Load Balancer target group to associate with the service.
    target_group_arn = var.target_group_arn

    # The name of the container to associate with the load balancer (as it appears in a container definition).
    container_name = var.container_name

    # The port on the container to associate with the load balancer.
    container_port = var.container_port
  }

  # If your service's tasks take a while to start and respond to Elastic Load Balancing health checks,
  # you can specify a health check grace period of up to 7,200 seconds. This grace period can prevent
  # the service scheduler from marking tasks as unhealthy and stopping them before they have time to come up.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-create-loadbalancer-rolling.html
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  # You can use either the version number (for example, 1.4.0) or LATEST.
  # If you specify LATEST, your tasks use the most current platform version available,
  # which may not be the most recent platform version.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
  platform_version = var.platform_version

  # The launch type on which to run your service.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html
  launch_type = "FARGATE"

  # Note that Fargate tasks do support only the REPLICA scheduling strategy.
  #
  # The replica scheduling strategy places and maintains the desired number of tasks across your cluster.
  # By default, the service scheduler spreads tasks across Availability Zones.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_replica
  scheduling_strategy = "REPLICA"

  lifecycle {
    # Ignore any changes to that count caused externally (e.g. Application Autoscaling).
    # https://www.terraform.io/docs/providers/aws/r/ecs_service.html#ignoring-changes-to-desired-count
    ignore_changes = [desired_count]
  }
}



# ECS Task Definitions
resource "aws_ecs_task_definition" "default" {
  count = var.enabled ? 1 : 0

  # A unique name for your task definition.
  family = var.name

  # The ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.
  execution_role_arn = var.create_ecs_task_execution_role ? join("", aws_iam_role.default.*.arn) : var.ecs_task_execution_role_arn

  # A list of container definitions in JSON format that describe the different containers that make up your task.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions
  container_definitions = var.container_definitions

  # The number of CPU units used by the task.
  # It can be expressed as an integer using CPU units, for example 1024, or as a string using vCPUs, for example 1 vCPU or 1 vcpu.
  # String values are converted to an integer indicating the CPU units when the task definition is registered.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
  cpu = var.cpu

  # The amount of memory (in MiB) used by the task.
  # It can be expressed as an integer using MiB, for example 1024, or as a string using GB, for example 1GB or 1 GB.
  # String values are converted to an integer indicating the MiB when the task definition is registered.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
  memory = var.memory

  # The launch type that the task is using.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#requires_compatibilities
  requires_compatibilities = var.requires_compatibilities

  # Fargate infrastructure support the awsvpc network mode.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#network_mode
  network_mode = "awsvpc"

  # A mapping of tags to assign to the resource.
  tags = merge({ "Name" = var.name }, var.tags)
}

# ECS Task Execution IAM Role
#
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html

# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "default" {
  count = local.enabled_ecs_task_execution

  name               = local.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = var.iam_path
  description        = var.description
  tags               = merge({ "Name" = local.iam_name }, var.tags)
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

# https://www.terraform.io/docs/providers/aws/r/iam_policy.html
resource "aws_iam_policy" "default" {
  count = local.enabled_ecs_task_execution

  name        = local.iam_name
  policy      = data.aws_iam_policy.ecs_task_execution.policy
  path        = var.iam_path
  description = var.description
}

# https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "default" {
  count = local.enabled_ecs_task_execution

  role       = aws_iam_role.default[0].name
  policy_arn = aws_iam_policy.default[0].arn
}

locals {
  iam_name                   = "${var.name}-ecs-task-execution"
  enabled_ecs_task_execution = var.enabled ? 1 : 0 && var.create_ecs_task_execution_role ? 1 : 0
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
