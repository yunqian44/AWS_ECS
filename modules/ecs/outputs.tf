output "ecs_service_id" {
  value       = join("", aws_ecs_service.default.*.id)
  description = "The Amazon Resource Name (ARN) that identifies the service."
}

output "ecs_service_name" {
  value       = join("", aws_ecs_service.default.*.name)
  description = "The name of the service."
}

output "ecs_service_cluster" {
  value       = join("", aws_ecs_service.default.*.cluster)
  description = "The Amazon Resource Name (ARN) of cluster which the service runs on."
}

output "ecs_service_iam_role" {
  value       = join("", aws_ecs_service.default.*.iam_role)
  description = "The ARN of IAM role used for ELB."
}

output "ecs_service_desired_count" {
  value       = join("", aws_ecs_service.default.*.desired_count)
  description = "The number of instances of the task definition."
}

output "ecs_task_definition_arn" {
  value       = join("", aws_ecs_task_definition.default.*.arn)
  description = "Full ARN of the Task Definition (including both family and revision)."
}

output "ecs_task_definition_family" {
  value       = join("", aws_ecs_task_definition.default.*.family)
  description = "The family of the Task Definition."
}

output "ecs_task_definition_revision" {
  value       = join("", aws_ecs_task_definition.default.*.revision)
  description = "The revision of the task in a particular family."
}
