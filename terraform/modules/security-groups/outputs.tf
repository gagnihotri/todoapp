output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "sg_id" {
  value = aws_security_group.web_sg.id
}
