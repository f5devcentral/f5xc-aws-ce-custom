output "f5xc_ce_outside_ips" {
  value =  values({ for nic in aws_network_interface.outside_map: nic.id => nic.private_ip } )
}
output "f5xc_ce_inside_ips" {
  value =  values({ for nic in aws_network_interface.inside_map: nic.id => nic.private_ip } )
}
output "f5xc_ce_outside_eips" {
  value =  values({ for eip in aws_eip.outside_eip_map: eip.id => eip.public_ip } )
}