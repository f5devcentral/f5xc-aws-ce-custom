variable "aws_region" {
  description = "REQUIRED: AWS Region to deploy the Customer Edge into"
  type        = string
}

variable "aws_access_key" {
  description = "REQUIRED: AWS programatic access key"
  type        = string
}

variable "aws_secret_key" {
  description = "REQUIRED: AWS programatic secret key"
  type        = string
}

variable "f5xc_ce_gateway_multi_node" {
  description = "OPTIONAL: Set to true to deploy a 3 node cluster of Customer Edges"
  type        = bool
  default     = false
}
variable "az1" {
  description = "OPTIONAL: AWS availability zone to deploy first Customer Edge into"
  type        = string
  default     = ""
}

variable "az2" {
  description = "OPTIONAL: AWS availability zone to deploy second Customer Edge into"
  type        = string
  default     = ""
}

variable "az3" {
  description = "OPTIONAL: AWS availability zone to deploy third Customer Edge into"
  type        = string
  default     = ""
}

variable "project_prefix" {
  description = "OPTIONAL: Provide a project name prefix that will be applied"
  type        = string
  default     = "demo"
}

variable "resourceOwner" {
  # used for "owner" tags in AWS
  description = "OPTIONAL: Provide owner of the deployment for tagging purposes"
  type        = string
  default     = "demo.user"
}

variable "ce1_outside_subnet_id" {
  description = "REQUIRED: The AWS subnet ID for the outside subnet of Customer Edge 1"
  type        = string
}

variable "ce1_inside_subnet_id" {
  description = "REQUIRED: The AWS subnet ID for the inside subnet of Customer Edge 1"
  type        = string
}


variable "ce2_outside_subnet_id" {
  description = "OPTIONAL: The AWS subnet ID for the outside subnet of Customer Edge 2"
  type        = string
  default     = ""
}

variable "ce2_inside_subnet_id" {
  description = "OPTIONAL: The AWS subnet ID for the inside subnet of Customer Edge 2"
  type        = string
  default     = ""
}

variable "ce3_outside_subnet_id" {
  description = "OPTIONAL: The AWS subnet ID for the outside subnet of Customer Edge 3"
  type        = string
  default     = ""
}

variable "ce3_inside_subnet_id" {
  description = "OPTIONAL: The AWS subnet ID for the inside subnet of Customer Edge 3"
  type        = string
  default     = ""

}

variable "outside_security_group" {
  description = "REQUIRED: The AWS security group ID for the outside interfaces"
  type        = string
}

variable "inside_security_group" {
  description = "REQUIRED: The AWS security group ID for the inside interfaces"
  type        = string
}


variable "amis" {
  description = "REQUIRED: The AWS amis for the Customer Edge image"
  type        = map(any)
  default = {
    "ca-central-1"   = "ami-052252c245ff77338"
    "af-south-1"     = "ami-0c22728f79f714ed1"
    "ap-east-1"      = "ami-0a6cf3665c0612f91"
    "ap-northeast-2" = "ami-01472d819351faf92"
    "ap-southeast-2" = "ami-03ff18dfb7f90eb54"
    "ap-south-1"     = "ami-0277ab0b4db359c93"
    "ap-northeast-1" = "ami-0384d075a36447e2a"
    "ap-southeast-1" = "ami-0d6463ee1e3727e84"
    "eu-central-1"   = "ami-06d5e0073d97ecf99"
    "eu-west-1"      = "ami-090680f491ad6d46a"
    "eu-west-3"      = "ami-03bd7c41ca1b586a8"
    "eu-south-1"     = "ami-0baafa10ffcd081b7"
    "eu-north-1"     = "ami-006c465449ed98c69"
    "eu-west-2"      = "ami-0df8a483722043a41"
    "me-south-1"     = "ami-094efc1a78169dd7c"
    "sa-east-1"      = "ami-07369c4b06cf22299"
    "us-east-1"      = "ami-089311edbe1137720"
    "us-east-2"      = "ami-01ba94b5a83adcb35"
    "us-west-1"      = "ami-092a2a07d2d3a445f"
    "us-west-2"      = "ami-07252e5ab4023b8cf"
  }
}

variable "instance_type" {
  description = "REQUIRED: The AWS instance type for the Customer Edge"
  type        = string
  default     = "t3.xlarge"
}

variable "instance_disk_size" {
  description = "OPTIONAL: The AWS disk size for the Customer Edge"
  type        = string
  default     = "40"
}
variable "sitelatitude" {
  description = "REQUIRED: Site Physical Location Latitude. See https://www.latlong.net/"
  type        = string
}
variable "sitelongitude" {
  description = "REQUIRED: Site Physical Location Longitude. See https://www.latlong.net/"
  type        = string
}
variable "clustername" {
  description = "REQUIRED: Customer Edge site cluster name."
  type        = string
}
variable "sitetoken" {
  description = "REQUIRED: Distributed Cloud Customer Edge site registration token."
  type        = string
  sensitive   = true
}