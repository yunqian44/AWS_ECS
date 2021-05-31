variable "enabled_security_group" {
  default     = false
  type        = string
  description = "Set to false to prevent the module from creating security_group"
}

variable "security_group_name" {
  type        = string
  description = "The name of the security group"
}

variable "security_group_vpc_id" {
  type        = string
  description = "VPC Id to associate with ECS Service."
}

variable "security_group_tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}

variable "source_cidr_blocks" {
  default     = ["0.0.0.0/0"]
  type        = list(string)
  description = "List of source CIDR blocks."
}

variable "from_port_ingress" {
  type        = string
  description = "The port on the security group from_port_ingress."
}

variable "to_port_ingress" {
  type        = string
  description = "The port on the security group to_port_ingress."
}

variable "from_port_egress" {
  type        = string
  description = "The port on the security group from_port_egress."
}

variable "to_port_egress" {
  type        = string
  description = "The port on the security group to_port_egress."
}





