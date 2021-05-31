output "security_group_id" {
  value       = join("", aws_security_group.default.*.id)
  description = "The ID of the ECS Service security group."
}

output "security_group_arn" {
  value       = join("", aws_security_group.default.*.arn)
  description = "The ARN of the ECS Service security group."
}

output "security_group_vpc_id" {
  value       = join("", aws_security_group.default.*.vpc_id)
  description = "The VPC ID of the ECS Service security group."
}

output "security_group_owner_id" {
  value       = join("", aws_security_group.default.*.owner_id)
  description = "The owner ID of the ECS Service security group."
}

output "security_group_name" {
  value       = join("", aws_security_group.default.*.name)
  description = "The name of the ECS Service security group."
}

output "security_group_description" {
  value       = join("", aws_security_group.default.*.description)
  description = "The description of the ECS Service security group."
}

output "security_group_ingress" {
  value       = flatten(aws_security_group.default.*.ingress)
  description = "The ingress rules of the ECS Service security group."
}

output "security_group_egress" {
  value       = flatten(aws_security_group.default.*.egress)
  description = "The egress rules of the ECS Service security group."
}
