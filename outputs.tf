output "account_id" {
  value = data.aws_caller_identity.me.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.me.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}
output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.private_b.id
}
output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "nat_eip" {
  value = aws_eip.nat_eip.public_ip
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}
