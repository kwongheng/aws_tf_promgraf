# Create a Null Resource and Provisioners
resource "null_resource" "name" {
  depends_on = [ aws_instance.prometheus_svr ]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type     = "ssh"
    host     =  aws_instance.prometheus_svr.public_ip  
    user     = "ubuntu"
    private_key = file("private-key/terraform-key.pem")
  }  

## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "private-key/terraform-key.pem"
    destination = "/tmp/terraform-key.pem"
  }
## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/terraform-key.pem"
    ]
  }

}

resource "time_sleep" "wait_before_exec" {
  create_duration = "2m"
}

resource "null_resource" "update_prometheus_config" {
  # Trigger on changes to Node Exporter instance
  triggers = {
    node_exporter_ip = aws_instance.app_svr.private_ip
  }

  # SSH connection to Prometheus instance
  connection {
    type        = "ssh"
    host        = aws_instance.prometheus_svr.public_ip
    user        = "ubuntu"
    private_key = file("private-key/terraform-key.pem")
  }

  # Append new Node Exporter to prometheus.yml
  provisioner "remote-exec" {
    inline = [
      "echo '  - job_name: \"node_exporter_${aws_instance.app_svr.id}\"' | sudo -u prometheus tee -a /etc/prometheus/prometheus.yml",
      "echo '    static_configs:' | sudo -u prometheus tee -a /etc/prometheus/prometheus.yml",
      "echo '      - targets: [\"${aws_instance.app_svr.private_ip}:9100\"]' | sudo -u prometheus tee -a /etc/prometheus/prometheus.yml",
      "sudo systemctl restart prometheus"
    ]
  }

  # Ensure this runs after Prometheus and Node Exporter instances
  depends_on = [aws_instance.prometheus_svr, aws_instance.app_svr, time_sleep.wait_before_exec]
}
