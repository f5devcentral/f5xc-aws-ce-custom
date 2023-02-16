provider "aws" {
  region = var.aws_region
}

# Create Random ID to Append to Builds to Avoid Naming Conflicts
resource "random_id" "buildSuffix" {
  byte_length = 2
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
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce_az2_outside.id
  associate_with_private_ip = aws_network_interface.f5xc_ce_az2_outside.private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az2_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_network_interface" "f5xc_ce_az3_inside" {
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
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce_az3_outside.id
  associate_with_private_ip = aws_network_interface.f5xc_ce_az3_outside.private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az3_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_instance" "f5xc_ce_az1" {
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  #root_block_device {
  #  volume_size = var.instance_disk_size
  #  volume_type = "gp3"
  #}
  get_password_data = false
  monitoring        = false
  availability_zone = var.az1

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  = "${var.sitelatitude}",
      sitelongitude = "${var.sitelongitude}"
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
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  #root_block_device {
  #  volume_size = var.instance_disk_size
  #  volume_type = "gp3"
  #}
  get_password_data = false
  monitoring        = false
  availability_zone = var.az2

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  = "${var.sitelatitude}",
      sitelongitude = "${var.sitelongitude}"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az2_outside.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az2_inside.id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-1"
  }
}

resource "aws_instance" "f5xc_ce_az3" {
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  #root_block_device {
  #  volume_size = var.instance_disk_size
  #  volume_type = "gp3"
  #}
  get_password_data = false
  monitoring        = false
  availability_zone = var.az3

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  = "${var.sitelatitude}",
      sitelongitude = "${var.sitelongitude}"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az3_outside.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce_az3_inside.id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-2"
  }
}