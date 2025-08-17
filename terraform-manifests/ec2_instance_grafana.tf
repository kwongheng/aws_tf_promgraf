# EC2 Instance
resource "aws_instance" "grafana_svr" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.instance_keypair
  user_data = file("${path.module}/setup_grafana_svr.sh")  
  vpc_security_group_ids = [ 
    data.aws_security_group.default.id, 
    aws_security_group.vpc-ssh.id, 
    aws_security_group.vpc-grafana.id  
  ]
  tags = {
    "Name" = "Grafana Server"
  }

}

