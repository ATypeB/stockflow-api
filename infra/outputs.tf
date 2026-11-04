output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.api.id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.api.public_ip
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = aws_dynamodb_table.products.name
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}