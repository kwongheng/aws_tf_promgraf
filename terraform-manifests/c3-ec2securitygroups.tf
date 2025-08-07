#setup default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# Create Security Group - SSH Traffic
resource "aws_security_group" "vpc-ssh" {
  name        = "vpc-ssh"
  description = "Dev VPC SSH"
  ingress {
    description = "Allow Port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.myip_address ]
  }

  egress {
    description = "Allow all ip and ports outbound"    
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-ssh"
  }
}

# Create Security Group - Web Traffic
resource "aws_security_group" "vpc-promsvr" {
  name        = "vpc-promsvr"
  description = "Dev VPC Prometheus Server"
  ingress {
    description = "Allow Port 9090"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [ var.myip_address ]
  }
  egress {
    description = "Allow all ip and ports outbound"    
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-promsvr"
  }
}

#node exporter
resource "aws_security_group" "vpc-nexport" {
  name        = "vpc-nexport"
  description = "Dev VPC Node Exporter"
  ingress {
    description = "Allow Port 9100"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    #cidr_blocks = [ data.aws_vpc.default.cidr_block ]
    security_groups = [ data.aws_security_group.default.id ]
  }
  egress {
    description = "Allow all ip and ports outbound"    
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-nexport"
  }
}

