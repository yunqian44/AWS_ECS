Terraform module which creates ECS Fargate resources on AWS.

## Description

Provision [ECS Service](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) and
[ECS Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html).

This module provides recommended settings:

- Fargate launch type
- Disable assign public ip address
