# Security Group for ECS Service
#
# NOTE: At this time you cannot use a Security Group with in-line rules
#       in conjunction with any Security Group Rule resources.
#       Doing so will cause a conflict of rule settings and will overwrite rules.
#
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "default" {
  count = var.enabled_security_group ? 1 : 0

  name   = var.security_group_name
  vpc_id = var.security_group_vpc_id
  tags   = merge({ "Name" = var.security_group_name }, var.security_group_tags)
}

# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "ingress" {
  count = var.enabled_security_group ? 1 : 0

  type              = "ingress"
  from_port         = var.from_port_ingress
  to_port           = var.to_port_ingress
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.default[0].id
}

resource "aws_security_group_rule" "egress" {
  count = var.enabled_security_group ? 1 : 0

  type              = "egress"
  from_port         = var.from_port_egress
  to_port           = var.to_port_egress
  protocol          = "-1"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.default[0].id
}
