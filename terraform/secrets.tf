data "aws_secretsmanager_secret" "private_key" {
  name = "ec2-private-key"
}

data "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id = data.aws_secretsmanager_secret.private_key
}
