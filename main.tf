provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  default_tags { 
    tags = var.default_tags
  }
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
}

# Create IAM policy
resource "aws_iam_policy" "f5xc_iam_policy" {
  count = var.create_iam_role ? 1 : 0
  name = "${var.f5xc_ce_iam_role_name}_policy"
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
  count = var.create_iam_role ? 1 : 0
  name = "${var.f5xc_ce_iam_role_name}"
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
  count = var.create_iam_role ? 1 : 0
  name = "${var.f5xc_ce_iam_role_name}"
  roles = [aws_iam_role.f5xc_role[0].name]
  policy_arn = aws_iam_policy.f5xc_iam_policy[0].arn
}

# Attach role to an instance profile
resource "aws_iam_instance_profile" "f5xc_profile" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.f5xc_ce_iam_role_name}"
  role  = aws_iam_role.f5xc_role[0].name
}




# Create Network Interfaces for Customer Edges
resource "aws_network_interface" "inside_map" {
  for_each = {
    for k, v in var.ce_settings : k => v
    if var.f5xc_ce_gateway_multi_nic 
  }
  subnet_id = each.value.inside_subnet_arn
  private_ips_count         = 1
  security_groups           = [var.inside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-${each.key}_inside-${random_id.buildSuffix.hex}"
  }
}
resource "aws_network_interface" "outside_map" {
  for_each = var.ce_settings
  subnet_id = each.value.outside_subnet_arn
  private_ips_count         = 1
  security_groups           = [var.outside_security_group]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-${each.key}_outside-${random_id.buildSuffix.hex}"
  }
}
resource "aws_eip" "outside_eip_map" {
  for_each = {
    for k, v in var.ce_settings : k => v
    if var.f5xc_ce_gateway_multi_nic 
  }
  domain                    = "vpc"
  network_interface         = aws_network_interface.outside_map["${each.key}"].id
  associate_with_private_ip = aws_network_interface.outside_map["${each.key}"].private_ip
  tags = {
    Name  = "${var.project_prefix}-${each.key}_outside_eipd-${random_id.buildSuffix.hex}"
  }
}

resource "aws_instance" "ce_map" {
  for_each = var.ce_settings
  ami           = var.f5xc_ce_gateway_multi_nic ? var.aws_region_config[var.aws_region]["multinic_ami"] : var.aws_region_config[var.aws_region]["singlenic_ami"]
  instance_type = var.instance_type
  iam_instance_profile = var.create_iam_role ? aws_iam_instance_profile.f5xc_profile[0].name : var.f5xc_ce_iam_role_name
  root_block_device {
    volume_size = var.instance_disk_size
    volume_type = "gp3"
  }
  get_password_data = false
  monitoring        = false
  availability_zone = each.value.availability_zone
  key_name = "${aws_key_pair.deployer.key_name}"

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  =  var.sitelatitude == "" ? var.aws_region_config[var.aws_region]["lattiude"] : var.sitelatitude,
      sitelongitude =  var.sitelongitude =="" ? var.aws_region_config[var.aws_region]["longitude"] : var.sitelongitude,
      sitesshrsakey = "${aws_key_pair.deployer.public_key}"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.outside_map["${each.key}"].id
    device_index         = 0
  }
  dynamic network_interface {
    for_each = var.f5xc_ce_gateway_multi_nic ? [aws_network_interface.inside_map] : []
    content { 
      network_interface_id = aws_network_interface.inside_map["${each.key}"].id
      device_index         = 1
    }
  }
  tags = {
    Name = "${var.project_prefix}-${each.key}-${random_id.buildSuffix.hex}"
    "kubernetes.io/cluster/${var.clustername}" = "owned"
    ves-io-site-name = "${var.clustername}"
  }
}