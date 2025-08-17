
output "prom_public_dns" {
    description = "Prometheus Public DNS"
    value = aws_instance.prometheus_svr.public_dns
}

output "prom_public_ip" {
    description = "Prometheus Public IP"
    value = aws_instance.prometheus_svr.public_ip
}

output "prom_private_ip" {
    description = "Prometheus Private IP"
    value = aws_instance.prometheus_svr.private_ip
}

output "graf_public_dns" {
    description = "Grafana Public DNS"
    value = aws_instance.grafana_svr.public_dns
}

output "gaf_public_ip" {
    description = "Grafana Public IP"
    value = aws_instance.grafana_svr.public_ip
}


output "app1_public_dns" {
    description = "App1 Public DNS"
    value = aws_instance.app_svr.public_dns
}

output "app1_public_ip" {
    description = "App1 Public IP"
    value = aws_instance.app_svr.public_ip
}

output "app1_private_ip" {
    description = "App1 Private IP"
    value = aws_instance.app_svr.private_ip
}

