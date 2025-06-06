# Security Group for SSH
resource "aws_security_group" "vpc-ssh" {
  name        = "${local.name}-vpc-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  # Ingress rules for SSH access
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Egress rules for ssh outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Tags for the security group
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc-ssh"
    }
  )
}

# Security Group for Web Traffic
resource "aws_security_group" "vpc-web" {
  name        = "${local.name}-vpc-web"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = var.vpc_id

# Ingress rules for HTTP and HTTPS access
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Egress rules for web outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Tags for the security group
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-vpc-web"
    }
  )
}


