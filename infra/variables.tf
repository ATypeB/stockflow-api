variable "aws_region" {
  description = "Região da AWS onde a infraestrutura será criada"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "stockflow"
}

variable "environment" {
  description = "Ambiente da aplicação"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "ID da AMI do Amazon Linux 2023 na região escolhida"
  type        = string
}

variable "allowed_cidr" {
  description = "Endereço IP autorizado a acessar a API"
  type        = string
}