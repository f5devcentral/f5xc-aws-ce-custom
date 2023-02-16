output "f5xc_ce_az1_eip" {
  value = aws_eip.f5xc_ce_az1_outside.public_ip
}

output "f5xc_ce_az2_eip" {
  value = aws_eip.f5xc_ce_az2_outside.public_ip
}

output "f5xc_ce_az3_eip" {
  value = aws_eip.f5xc_ce_az3_outside.public_ip
}