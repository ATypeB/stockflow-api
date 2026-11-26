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

variable "instance_profile_name" {
  description = "Instance profile pré-existente no AWS Academy (roles IAM não podem ser criadas no laboratório)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "allowed_cidr" {
  description = "Bloco CIDR autorizado a acessar a API (ex.: 203.0.113.10/32)"
  type        = string
}
