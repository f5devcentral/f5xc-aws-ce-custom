variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}
variable "az1" {
  type = string
}

variable "az2" {
  type = string
}

variable "az3" {
  type = string
}

variable "f5xc_ce_gateway_multi_node" {
  type    = bool
  default = false
}

variable "project_prefix" {
  type    = string
  default = "demo"
}

variable "resourceOwner" {
  # used for "owner" tags in AWS
  type        = string
  description = "Owner of the deployment for tagging purposes"
  default     = "demo.user"
}

variable "az1_outside_subnet_id" {
  type        = string
  description = "The subnet ID for the outside subnet in Availability Zone 1"
}

variable "az1_inside_subnet_id" {
  type        = string
  description = "The subnet ID for the inside subnet in Availability Zone 1"
}


variable "az2_outside_subnet_id" {
  type        = string
  description = "The subnet ID for the outside subnet in Availability Zone 2"
}

variable "az2_inside_subnet_id" {
  type        = string
  description = "The subnet ID for the inside subnet in Availability Zone 2"
}

variable "az3_outside_subnet_id" {
  type        = string
  description = "The subnet ID for the outside subnet in Availability Zone 3"
}

variable "az3_inside_subnet_id" {
  type        = string
  description = "The subnet ID for the inside subnet in Availability Zone 3"
}

variable "outside_security_group" {
  type        = string
  description = "The Security Group ID for the outside interfaces"
}

variable "inside_security_group" {
  type        = string
  description = "The Security Group ID for the inside interfaces"
}


variable "amis" {
  type = map(any)
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
  type    = string
  default = "t3.xlarge"
}

variable "instance_disk_size" {
  type    = string
  default = "40"
}
variable "sitelatitude" {
  type        = string
  description = "REQUIRED: Site Physical Location Latitude. See https://www.latlong.net/"
}
variable "sitelongitude" {
  type        = string
  description = "REQUIRED: Site Physical Location Longitude. See https://www.latlong.net/"
}
variable "clustername" {
  type        = string
  description = "REQUIRED: Site Cluster Name."
}
variable "sitetoken" {
  type        = string
  sensitive   = true
  description = "REQUIRED: Site Registration Token."
}