output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}

output "master_sg" {
  value = aws_security_group.master_sg.id
}

output "worker_sg" {
  value = aws_security_group.worker_sg.id
}