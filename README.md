# F5XC AWS CE MULTINIC

## Introduction

Customer AWS deployments vary greatly from one customer to the next.  Utilizing Terraform, deployments can be custom built to meet the desired requirements.  This solution uses Terraform to deploy either a single node F5 Distributed Cloud Customer Edge or a three node F5 Distributed Cloud cluster into an existing AWS environment.

## Prerequisites
- **Important**: Customer Edges must be deployed using programatic access (Access Key and Secret Access Key). Customer Edges can not be deployed utilizing AWS Security Token Service (STS).
- An existing AWS environment comprised of the following components is required:
  - At least one subnet for the Customer Edge outside interfaces.  When deploying a three node cluster if you don't specify separate subnets for each Customer Edge, a single subnet will be used.
  - At least one security group that allows outbound access and allows inbound communications between the outside interfaces of the Customer Edges if deploying a three node cluster.
- The latitude and longitude for the AWS site.  This is used to determine the closest Regional Edges.
- A clustername for the site.  This is the site name that will be displayed in the Distributed Cloud console.
- A site token used to register the Customer Edge to Distributed Cloud.

## Requirements

| Name | Version |
| terraform | ~> 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

## Inputs
| Name | Description | Type | Default |
|------|-------------|------|---------------------|
| aws_region | REQUIRED: AWS Region to deploy the Customer Edge into | string | |
|aws_access_key | REQUIRED: AWS programatic access key | string | |
| aws_secret_key | REQUIRED: AWS programatic secret key | string | |
| f5xc_ce_gateway_multi_node | OPTIONAL: Set to true to deploy a 3 node cluster of Customer Edges | bool | false |
| az1 | OPTIONAL: AWS availability zone to deploy first Customer Edge into | string | "" |
| az2 | OPTIONAL: AWS availability zone to deploy second Customer Edge into | string | "" |
| az3 | OPTIONAL: AWS availability zone to deploy third Customer Edge into | string | "" |
| project_prefix | OPTIONAL: Provide a project name prefix that will be applied | string | demo |
| resource_owner | OPTIONAL: Provide owner of the deployment for tagging purposes | string | demo.user |
| ce1_outside_subnet_id | REQUIRED: The AWS subnet ID for the outside subnet of Customer Edge 1 | string | |
| ce1_inside_subnet_id | REQUIRED: The AWS subnet ID for the inside subnet of Customer Edge 1 | string | |
| ce2_outside_subnet_id | OPTIONAL: The AWS subnet ID for the outside subnet of Customer Edge 2 | string | "" |
| ce2_inside_subnet_id" | OPTIONAL: The AWS subnet ID for the inside subnet of Customer Edge 2 | string | "" |
| ce3_outside_subnet_id" | OPTIONAL: The AWS subnet ID for the outside subnet of Customer Edge 3 | string | "" |
| ce3_inside_subnet_id" | OPTIONAL: The AWS subnet ID for the inside subnet of Customer Edge 3 | string | "" |
| outside_security_group | REQUIRED: The AWS security group ID for the outside interfaces | string | |
| inside_security_group | REQUIRED: The AWS security group ID for the inside interfaces | string | |
| amis | REQUIRED: The AWS amis for the Customer Edge image | map(any) |  ca-central-1 = ami-052252c245ff77338<br>af-south-1 = ami-0c22728f79f714ed1<br>ap-east-1 = ami-0a6cf3665c0612f91<br>ap-northeast-2 = ami-01472d819351faf92<br>ap-southeast-2 = ami-03ff18dfb7f90eb54<br>ap-south-1 = ami-0277ab0b4db359c93<br>ap-northeast-1 = ami-0384d075a36447e2a<br>ap-southeast-1 = ami-0d6463ee1e3727e84<br>eu-central-1 = ami-06d5e0073d97ecf99<br>eu-west-1 = ami-090680f491ad6d46a<br>eu-west-3 = ami-03bd7c41ca1b586a8<br>eu-south-1 = ami-0baafa10ffcd081b7<br>eu-north-1 = ami-006c465449ed98c69<br>eu-west-2 = ami-0df8a483722043a41<br>me-south-1 = ami-094efc1a78169dd7c<br>sa-east-1 = ami-07369c4b06cf22299<br>us-east-1 = ami-089311edbe1137720<br>us-east-2 = ami-01ba94b5a83adcb35<br>us-west-1 = ami-092a2a07d2d3a445f<br>us-west-2 = ami-07252e5ab4023b8cf|
| instance_type | REQUIRED: The AWS instance type for the Customer Edge | string | t3.xlarge |
| instance_disk_size | OPTIONAL: The AWS disk size for the Customer Edge | string |40 |
| sitelatitude | REQUIRED: Site Physical Location Latitude. See https://www.latlong.net/ | string | |
| sitelongitude | REQUIRED: Site Physical Location Longitude. See https://www.latlong.net/ | string | |
| clustername | REQUIRED: Customer Edge site cluster name. | string | |
| sitetoken | REQUIRED: Distributed Cloud Customer Edge site registration token | string | |

## Outputs
| Name | Description |
| f5xc_ce1_eip | Customer Edge 1 external public IP |
| f5xc_ce1_outside_ip | Customer Edge 1 outside private IP |
| f5xc_ce2_eip | Customer Edge 2 external public IP |
| f5xc_ce2_outside_ip | Customer Edge 2 outside private IP |
| f5xc_ce3_eip | Customer Edge 3 external public IP |
| f5xc_ce3_outside_ip | Customer Edge 3 outside private IP |

## Deployment
For deployment you can use the traditional terraform commands.

```bash
terraform init
terraform plan
terraform apply
```

## Destruction

For destruction / tear down you can use the trafitional terraform commands.

```bash
terraform destroy
```
