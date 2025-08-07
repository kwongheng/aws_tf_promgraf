
output "prom_public_dns" {
    description = "Public DNS"
    value = aws_instance.prometheus_svr.public_dns
}

output "prom_public_ip" {
    description = "Public IP"
    value = aws_instance.prometheus_svr.public_ip
}


output "app1_public_dns" {
    description = "Public DNS"
    value = aws_instance.app_svr.public_dns
}

output "app1_public_ip" {
    description = "Public IP"
    value = aws_instance.app_svr.public_ip
}

output "app1_private_ip" {
    description = "Private IP"
    value = aws_instance.app_svr.private_ip
}


# Output - For Loop with List
# output "public_dns" {
#    description = "Public DNS"
#    value = [for instance in aws_instance.prometheus_svr: instance.public_dns]
# }

# # Output - For Loop with Map
# output "for_output_map1" {
#   description = "For Loop with Map"
#   value = {for instance in aws_instance.prometheus_svr: instance.id => instance.public_dns}
# }

# Output - For Loop with Map Advanced
# output "for_output_map2" {
#   description = "For Loop with Map - Advanced"
#   value = {for c, instance in aws_instance.prometheus_svr: c => instance.public_dns}
# }

# Output Legacy Splat Operator (Legacy) - Returns the List
/*
output "legacy_splat_instance_publicdns" {
  description = "Legacy Splat Operator"
  value = aws_instance.myec2vm.*.public_dns
}
*/

# Output Latest Generalized Splat Operator - Returns the List
# output "latest_splat_instance_publicdns" {
#   description = "Generalized latest Splat Operator"
#   value = aws_instance.prometheus_svr[*].public_dns
# }