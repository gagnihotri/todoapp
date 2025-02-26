data "aws_secretsmanager_secret" "private_key" {
  name = "ec2-private-key"
}

data "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id = data.aws_secretsmanager_secret.private_key.id
}

output "decoded_secret" {
  value = jsondecode(data.aws_secretsmanager_secret_version.private_key_version.secret_string)["ec2-key"]
  sensitive = true
}
