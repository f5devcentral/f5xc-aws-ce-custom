# F5XC AWS CE CUSTOM

## Introduction

Customer AWS deployments vary greatly from one customer to the next.  Utilizing Terraform, deployments can be custom built to meet the desired requirements.  This solution uses Terraform to deploy either a single node F5 Distributed Cloud Customer Edge or a three node F5 Distributed Cloud cluster into an existing AWS environment.  Customers can deploy multi-nic CE nodes or single NIC CE nodes.

## Prerequisites
- **Important**: Customer Edges must be deployed using programatic access (Access Key and Secret Access Key). Customer Edges can not be deployed utilizing AWS Security Token Service (STS).
- An existing AWS environment comprised of the following components is required:
  - At least one subnet for the Customer Edge outside interfaces.  When deploying a three node cluster if you don't specify separate subnets for each Customer Edge, a single subnet will be used.
  - At least one security group that allows outbound access and allows inbound communications between the outside interfaces of the Customer Edges if deploying a three node cluster.
- The AWS region, subnet ARNs, and Security Group ARNs to be assigned to ENIs.
  - The latitude and longitude for the AWS region will be looked up automatically, however you can override this by specifying longitude and latitude.  This is used to determine the closest Regional Edges.
- A clustername for the site.  This is the site name that will be displayed in the Distributed Cloud console.
- A site token used to register the Customer Edge to Distributed Cloud.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

## Inputs
| Name                       | Description | Type | Default |
| -----                      | ----------- | ---- | ------- | 
| aws_region                 | REQUIRED: AWS Region to deploy the Customer Edge into                                                                      | string   |                                      |
| aws_access_key             | REQUIRED: AWS programatic access key                                                                                       | string   |                                      |
| aws_secret_key             | REQUIRED: AWS programatic secret key                                                                                       | string   |                                      |
| outside_security_group     | REQUIRED: The AWS security group ID for the outside interfaces                                                             | string   |                                      |
| inside_security_group      | OPTIONAL: The AWS security group ID for the inside interfaces  (REQUIRED for Mutli-NIC deployments.)                       | string   |                                      | 
| clustername                | REQUIRED: Customer Edge site cluster name.                                                                                 | string   |                                      |
| sitetoken                  | REQUIRED: Distributed Cloud Customer Edge site registration token                                                          | string   |                                      |
| ce_settings                | REQUIRED: MAP of CE Settings: "ce-name" = { availability_zone = "", outside_subnet_arn = "", inside_subnet_arn = ""}       | map(any) |                                      |
| default_tags               | OPTIONAL: MAP of AWS Tags to be added to AWS resources                                                                     | map(any) |                                      |
| f5xc_ce_gateway_multi_nic  | OPTIONAL: Set to true to deploy Customer Edges with multiple network interfaces. False deploys a single nic node.          | bool     | false                                |
| f5xc_ce_assign_eip         | OPTIONAL: Set to true to deploy a EIP on the outside interface, false to deploy with no EIP.                               | bool     | false                                |
| project_prefix             | OPTIONAL: Provide a project name prefix that will be applied                                                               | string   | demo                                 |
| instance_type              | OPTIONAL: The AWS instance type for the Customer Edge                                                                      | string   | t3.xlarge                            |
| instance_disk_size         | OPTIONAL: The AWS disk size for the Customer Edge in GB.  Minimum value is 40 GB.                                          | string   | 80                                   |
| sitelatitude               | OPTIONAL: Site Physical Location Latitude, if you want to override the AWS region latitude. See https://www.latlong.net/   | string   |                                      |
| sitelongitude              | OPTIONAL: Site Physical Location Longitude, if you want to override the AWS region longitude. See https://www.latlong.net/ | string   |                                      |

## Example Multi-Node Multi-NIC terraform.tfvars:
```
aws_region                 = "us-east-1"
aws_access_key             = "00000000000000000000"
aws_secret_key             = "000000/00000000+/00000000000000000000000"
create_iam_role            = false
f5xc_ce_iam_role_name      = "f5xc_ce_iam_role"
f5xc_ce_gateway_multi_nic  = true
f5xc_ce_assign_eip         = true
project_prefix             = "exampleProject"
resource_owner             = "owner@example.com"
outside_security_group     = "sg-00000000000000000"
inside_security_group      = "sg-00000000000000000"
clustername                = "exampleProject-tf-aws-useast1"
sitetoken                  = "00000000-0000-0000-0000-000000000000"
ce_settings   = {
    "f5xc_ce_1" = { availability_zone = "us-east-1a", outside_subnet_arn = "subnet-00000000000000000", inside_subnet_arn = "subnet-00000000000000000"}
    "f5xc_ce_2" = { availability_zone = "us-east-1b", outside_subnet_arn = "subnet-00000000000000000", inside_subnet_arn = "subnet-00000000000000000"}
    "f5xc_ce_3" = { availability_zone = "us-east-1c", outside_subnet_arn = "subnet-00000000000000000", inside_subnet_arn = "subnet-00000000000000000"}
}
default_tags = {
    "Owner" = "blah@example.com"
    "tagname" = "tagvalue"
    "ves-io-creator-id" = "blah@example.com"
    "environment" = "TestDev"
}
```

## Example Single-Node Single-NIC terraform.tfvars:
```
aws_region                 = "us-east-2"
aws_access_key             = "00000000000000000000"
aws_secret_key             = "000000/00000000+/00000000000000000000000"
create_iam_role            = true
f5xc_ce_gateway_multi_nic  = false
f5xc_ce_assign_eip         = false
project_prefix             = "exampleProject"
outside_security_group     = "sg-00000000000000000"
inside_security_group      = ""
clustername                = "exampleProject-tf-aws-useast2"
sitetoken                  = "00000000-0000-0000-0000-000000000000"
ce_settings   = {
    "f5xc_ce_1" = { availability_zone = "us-east-2a", outside_subnet_arn = "subnet-00000000000000000", inside_subnet_arn = ""}
}
default_tags = {
    "Owner" = "blah@example.com"
    "tagname" = "tagvalue"
    "ves-io-creator-id" = "blah@example.com"
    "environment" = "TestDev"
}
```

## Outputs
| Name | Description |
|------|-------------|
| f5xc_ce_inside_ips   | List of CE Inside Subnet Private IP addresses  |
| f5xc_ce_outside_eips | List of CE Outside Subnet Public IP addresses  |
| f5xc_ce_outside_ips  | List of CE Outside Subnet Private IP addresses | 

## Deployment
For deployment you can use the traditional terraform commands.

```bash
terraform init
terraform plan
terraform apply
```

## Destruction

For destruction / tear down you can use the traditional terraform commands.

```bash
terraform destroy
```
