# EC2 Instance
resource "aws_instance" "prometheus_svr" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.instance_keypair
  user_data = file("${path.module}/setup_prometheus_svr.sh")  
  vpc_security_group_ids = [ 
    data.aws_security_group.default.id, 
    aws_security_group.vpc-ssh.id, 
    aws_security_group.vpc-promsvr.id  
  ]
  tags = {
    "Name" = "Prometheus Server"
  }

}

