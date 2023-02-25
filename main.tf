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
    Owner = var.resource_owner
  }
}

# Create IAM policy
resource "aws_iam_policy" "f5xc_iam_policy" {
  name = "f5xc_iam_policy"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            "Action" = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyVolume",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateRoute",
                "ec2:DeleteRoute",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteVolume",
                "ec2:DetachVolume",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DescribeVpcs",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:AttachLoadBalancerToSubnets",
                "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateLoadBalancerPolicy",
                "elasticloadbalancing:CreateLoadBalancerListeners",
                "elasticloadbalancing:ConfigureHealthCheck",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteLoadBalancerListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DetachLoadBalancerFromSubnets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "iam:CreateServiceLinkedRole",
                "kms:DescribeKey"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]

  })
}

# Create a role
resource "aws_iam_role" "f5xc_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    "Statement" = [
        {
            "Sid" = "",
            "Effect" = "Allow",
            "Principal" = {
                "Service" = "ec2.amazonaws.com"
            },
            "Action" = "sts:AssumeRole"
        }
    ]
  })
}

# Attach role to policy
resource "aws_iam_policy_attachment" "f5xc_policy_role" {
  name = "f5xc_policy_role"
  roles = [aws_iam_role.f5xc_role.name]
  policy_arn = aws_iam_policy.f5xc_iam_policy.arn
}

# Attach role to an instance profile
resource "aws_iam_instance_profile" "f5xc_profile" {
  name = "f5xc_profile"
  role = aws_iam_role.f5xc_role.name
}
# Create Network Interfaces for Customer Edges
resource "aws_network_interface" "f5xc_ce1_inside" {
  subnet_id                 = var.ce1_inside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.inside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce1_inside-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_network_interface" "f5xc_ce1_outside" {
  subnet_id                 = var.ce1_outside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.outside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce1_outside-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_eip" "f5xc_ce1_outside" {
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce1_outside.id
  associate_with_private_ip = aws_network_interface.f5xc_ce1_outside.private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce1_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_network_interface" "f5xc_ce2_inside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.ce2_inside_subnet_id != "" ? var.ce2_inside_subnet_id : var.ce1_inside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.inside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce2_inside-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_network_interface" "f5xc_ce2_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.ce2_outside_subnet_id != "" ? var.ce2_outside_subnet_id : var.ce1_outside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.outside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce2_outside-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_eip" "f5xc_ce2_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce2_outside[0].id
  associate_with_private_ip = aws_network_interface.f5xc_ce2_outside[0].private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce2_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_network_interface" "f5xc_ce3_inside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.ce3_inside_subnet_id != "" ? var.ce3_inside_subnet_id : var.ce1_inside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.inside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce3_inside-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_network_interface" "f5xc_ce3_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  subnet_id                 = var.ce3_outside_subnet_id != "" ? var.ce3_outside_subnet_id : var.ce1_outside_subnet_id
  private_ips_count         = 1
  security_groups           = [var.outside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_ce3_outside-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_eip" "f5xc_ce3_outside" {
  count                     = var.f5xc_ce_gateway_multi_node ? 1 : 0
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce3_outside[0].id
  associate_with_private_ip = aws_network_interface.f5xc_ce3_outside[0].private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce_az3_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_instance" "f5xc_ce1" {
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.f5xc_profile.name
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
    network_interface_id = aws_network_interface.f5xc_ce1_outside.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce1_inside.id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-0"
    "kubernetes.io/cluster/${var.clustername}" = "owned"
    ves-io-site-name = "${var.clustername}"
  }
}

resource "aws_instance" "f5xc_ce2" {
  count         = var.f5xc_ce_gateway_multi_node ? 1 : 0
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.f5xc_profile.name

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
    network_interface_id = aws_network_interface.f5xc_ce2_outside[0].id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce2_inside[0].id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-1"
    "kubernetes.io/cluster/${var.clustername}" = "owned"
    ves-io-site-name = "${var.clustername}"
  }
}

resource "aws_instance" "f5xc_ce3" {
  count         = var.f5xc_ce_gateway_multi_node ? 1 : 0
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.f5xc_profile.name

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
    network_interface_id = aws_network_interface.f5xc_ce3_outside[0].id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce3_inside[0].id
    device_index         = 1
  }
  tags = {
    Name = "${var.project_prefix}-master-2"
    "kubernetes.io/cluster/${var.clustername}" = "owned"
    ves-io-site-name = "${var.clustername}"
  }
}