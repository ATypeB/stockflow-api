resource "aws_instance" "api" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.api.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-api"
    Project     = var.project_name
    Environment = var.environment
  }
}