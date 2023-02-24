output "f5xc_ce_az1_eip" {
  value = aws_eip.f5xc_ce1_outside.public_ip
}

output "f5xc_ce_az1_outside_ip" {
  value = aws_network_interface.f5xc_ce1_outside.private_ip
}
output "f5xc_ce_az2_eip" {
  value = var.f5xc_ce_gateway_multi_node ? aws_eip.f5xc_ce2_outside[0].public_ip : null
}

output "f5xc_ce_az2_outside_ip" {
  value = var.f5xc_ce_gateway_multi_node ? aws_network_interface.f5xc_ce2_outside[0].private_ip : null
}

output "f5xc_ce_az3_eip" {
  value = var.f5xc_ce_gateway_multi_node ? aws_eip.f5xc_ce3_outside[0].public_ip : null
}

output "f5xc_ce_az3_outside_ip" {
  value = var.f5xc_ce_gateway_multi_node ? aws_network_interface.f5xc_ce3_outside[0].private_ip : null
}