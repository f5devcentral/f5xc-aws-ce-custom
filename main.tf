provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create Random ID to Append to Builds to Avoid Naming Conflicts
resource "random_id" "buildSuffix" {
  byte_length = 2
}

resource "tls_private_key" "newkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "newkey_pem" {
  # create a new local ssh identity
  filename        = "${abspath(path.root)}/.ssh/${var.project_prefix}-key-${random_id.buildSuffix.hex}.pem"
  content         = tls_private_key.newkey.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "deployer" {
  # create a new AWS ssh identity
  key_name   = "${var.project_prefix}-key-${random_id.buildSuffix.hex}"
  public_key = tls_private_key.newkey.public_key_openssh
  tags = {
    Owner = var.resourceOwner
  }
}

# Create Network Interfaces for Customer Edges
resource "aws_network_interface" "f5xc_ce_az1_inside" {
  subnet_id                 = var.az1_inside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.inside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az1_inside-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_network_interface" "f5xc_ce_az1_outside" {
  subnet_id                 = var.az1_outside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.outside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az1_outside-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_eip" "f5xc_ce_az1_outside" {
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce_az1_outside.id
  associate_with_private_ip = aws_network_interface.f5xc_ce_az1_outside.private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az1_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_network_interface" "f5xc_ce_az2_inside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.az2_inside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.inside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az2_inside-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_network_interface" "f5xc_ce_az2_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.az2_outside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.outside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az2_outside-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_eip" "f5xc_ce_az2_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce_az2_outside[0].id
  associate_with_private_ip = aws_network_interface.f5xc_ce_az2_outside[0].private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az2_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_network_interface" "f5xc_ce_az3_inside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.az3_inside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.inside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az3_inside-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_network_interface" "f5xc_ce_az3_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.az3_outside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.outside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az3_outside-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_eip" "f5xc_ce_az3_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce_az3_outside[0].id
  associate_with_private_ip = aws_network_interface.f5xc_ce_az3_outside[0].private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az3_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_instance" "f5xc_ce_az1" {
  ami                  = var.amis[var.aws_region]
  instance_type        = var.instance_type
  root_block_device {
    volume_size = var.instance_disk_size
    volume_type = "gp3"
  }
  get_password_data = false
  monitoring        = false
  availability_zone = var.az1

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  = "${var.sitelatitude}",
      sitelongitude = "${var.sitelongitude}",
      sitesshrsakey = "${tls_private_key.newkey.private_key_pem}"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az1_outside.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az1_inside.id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-0"
  }
}

resource "aws_instance" "f5xc_ce_az2" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.instance_disk_size
    volume_type = "gp3"
  }
  get_password_data = false
  monitoring        = false
  availability_zone = var.az2

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  = "${var.sitelatitude}",
      sitelongitude = "${var.sitelongitude}",
      sitesshrsakey = "${tls_private_key.newkey.private_key_pem}"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az2_outside[0].id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az2_inside[0].id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-1"
  }
}

resource "aws_instance" "f5xc_ce_az3" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.instance_disk_size
    volume_type = "gp3"
  }
  get_password_data = false
  monitoring        = false
  availability_zone = var.az3

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  = "${var.sitelatitude}",
      sitelongitude = "${var.sitelongitude}",
      sitesshrsakey = "${tls_private_key.newkey.private_key_pem}"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az3_outside[0].id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az3_inside[0].id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-2"
  }
}