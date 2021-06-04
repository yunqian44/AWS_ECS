output "ecs_service_id" {
  value = module.ecs_fargate.ecs_service_id
}

output "ecs_service_name" {
  value = module.ecs_fargate.ecs_service_name
}

output "ecs_service_cluster" {
  value = module.ecs_fargate.ecs_service_cluster
}

output "ecs_service_iam_role" {
  value = module.ecs_fargate.ecs_service_iam_role
}

output "ecs_service_desired_count" {
  value = module.ecs_fargate.ecs_service_desired_count
}

output "security_group_id" {
  value = module.securitygroup.security_group_id
}

output "security_group_arn" {
  value = module.securitygroup.security_group_arn
}

output "security_group_vpc_id" {
  value = module.securitygroup.security_group_vpc_id
}

output "security_group_owner_id" {
  value = module.securitygroup.security_group_owner_id
}

output "security_group_name" {
  value = module.securitygroup.security_group_name
}

output "security_group_description" {
  value = module.securitygroup.security_group_description
}

output "security_group_ingress" {
  value = module.securitygroup.security_group_ingress
}

output "security_group_egress" {
  value = module.securitygroup.security_group_egress
}

output "ecs_task_definition_arn" {
  value = module.ecs_fargate.ecs_task_definition_arn
}

output "ecs_task_definition_family" {
  value = module.ecs_fargate.ecs_task_definition_family
}

output "ecs_task_definition_revision" {
  value = module.ecs_fargate.ecs_task_definition_revision
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}

output "iam_policy_ecs_task_execution_id" {
  value = aws_iam_policy.ecs_task_execution.id
}

output "iam_policy_ecs_task_execution_arn" {
  value = aws_iam_policy.ecs_task_execution.arn
}
output "iam_policy_ecs_task_execution_name" {
  value = aws_iam_policy.ecs_task_execution.name
}

output "iam_policy_ecs_task_execution_path" {
  value = aws_iam_policy.ecs_task_execution.path
}
