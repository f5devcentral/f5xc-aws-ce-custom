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

variable "create_iam_role" {
  description = "OPTIONAL: Set to true to create the IAM policy & role for the instance."
  type        = bool
  default     = true
}
variable "f5xc_ce_iam_role_name" {
  description = "OPTIONAL: Name of IAM ROLE to create or name to reference to existing role if one already exists."
  type        = string
  default     = "f5xc_ce_iam_role"
}
variable "f5xc_ce_gateway_multi_nic" {
  description = "OPTIONAL: Set to true to deploy a multi nic cluster of Customer Edges"
  type        = bool
  default     = false
}

variable "f5xc_ce_assign_eip" {
  description = "OPTIONAL: Set to true to assign an EIP on the outside interface of Customer Edges"
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

variable "outside_security_group" {
  description = "REQUIRED: The AWS security group ID for the outside interfaces"
  type        = string
}

variable "inside_security_group" {
  description = "REQUIRED: The AWS security group ID for the inside interfaces"
  type        = string
}

variable "default_tags" {
  description = "OPTIONAL: Map of tag name & value to be added to each AWS object."
  type        = map(any)
}

variable "ce_settings" {
  description = "REQUIRED: The az, subnet, etc for each Customer Edge instance."
  type        = map(any)
}

variable "aws_region_config" {
  // Lattiude & Longitude Pulled from: https://github.com/turnkeylinux/aws-datacenters/blob/master/input/datacenters
  // AMIs pulled from: 
  description = "OPTIONAL: The AWS amis for the Customer Edge Multi-NIC image"
  type        = map(any)
  default = {
    "us-east-1"       = {
      "multinic_ami"  = "ami-089311edbe1137720"
      "singlenic_ami" = "ami-0f94aee77d07b0094"
      "lattiude"      = "38.13"
      "longitude"     = "-78.45"
    }
    "us-east-2"       = {
      "multinic_ami"  = "ami-01ba94b5a83adcb35"
      "singlenic_ami" = "ami-0660aaf7b6edaa980"
      "lattiude"      = "39.96"
      "longitude"     = "-83"
    }
    "us-west-1"       = {
      "multinic_ami"  = "ami-092a2a07d2d3a445f"
      "singlenic_ami" = "ami-0cf44e35e2aecacb4"
      "lattiude"      = "37.35"
      "longitude"     = "-121.96"
    }
    "us-west-2"       = {
      "multinic_ami"  = "ami-07252e5ab4023b8cf"
      "singlenic_ami" = "ami-0cba83d31d405a8f5"
      "lattiude"      = "46.15"
      "longitude"     = "-123.88"
    }
    "ca-central-1"    = {
      "multinic_ami"  = "ami-052252c245ff77338"
      "singlenic_ami" = "ami-0ddc009ae69986eb4"
      "lattiude"      = "45.5"
      "longitude"     = "-73.6"
    }
    "ap-east-1"       = {
      "multinic_ami"  = "ami-0a6cf3665c0612f91"
      "singlenic_ami" = "ami-03cf35954fb9084fc"
      "lattiude"      = "22.27"
      "longitude"     = "114.16"
    }
    "ap-northeast-2"       = {
      "multinic_ami"  = "ami-01472d819351faf92"
      "singlenic_ami" = "ami-04f6d5781039d2f88"
      "lattiude"      = "37.56"
      "longitude"     = "126.98"
    }
    "ap-southeast-2"       = {
      "multinic_ami"  = "ami-03ff18dfb7f90eb54"
      "singlenic_ami" = "ami-0ae68f561b7d20682"
      "lattiude"      = "-33.86"
      "longitude"     = "151.2"
    }
    "ap-south-1"       = {
      "multinic_ami"  = "ami-0277ab0b4db359c93"
      "singlenic_ami" = "ami-099c0c7e19e1afd16"
      "lattiude"      = "19.08"
      "longitude"     = "72.88"
    }
    "ap-northeast-1"       = {
      "multinic_ami"  = "ami-0384d075a36447e2a"
      "singlenic_ami" = "ami-07dac882268159d52"
      "lattiude"      = "35.41"
      "longitude"     = "193.42"
    }
    "ap-southeast-1"       = {
      "multinic_ami"  = "ami-0d6463ee1e3727e84"
      "singlenic_ami" = "ami-0dba294abe676bd58"
      "lattiude"      = "1.37"
      "longitude"     = "103.8"
    }
    "eu-central-1"       = {
      "multinic_ami"  = "ami-06d5e0073d97ecf99"
      "singlenic_ami" = "ami-027625cb269f5d7e9"
      "lattiude"      = "50"
      "longitude"     = "8"
    }
    "eu-west-1"       = {
      "multinic_ami"  = "ami-090680f491ad6d46a"
      "singlenic_ami" = "ami-01baaca2a3b1b0114"
      "lattiude"      = "53"
      "longitude"     = "-8"
    }
    "eu-west-2"       = {
      "multinic_ami"  = "ami-0df8a483722043a41"
      "singlenic_ami" = "ami-05f5a414a42961df6"
      "lattiude"      = "51"
      "longitude"     = "-0.1"
    }
    "eu-west-3"       = {
      "multinic_ami"  = "ami-03bd7c41ca1b586a8"
      "singlenic_ami" = "ami-0e1361351f9205511"
      "lattiude"      = "48.86"
      "longitude"     = "2.35"
    }
    "eu-south-1"       = {
      "multinic_ami"  = "ami-0baafa10ffcd081b7"
      "singlenic_ami" = "ami-00cb6474298a310af"
      "lattiude"      = "45.43"
      "longitude"     = "9.29"
    }
    "eu-north-1"       = {
      "multinic_ami"  = "ami-006c465449ed98c69"
      "singlenic_ami" = "ami-0366c929eb2ac407b"
      "lattiude"      = "59.25"
      "longitude"     = "17.81"
    }
    "me-south-1"       = {
      "multinic_ami"  = "ami-094efc1a78169dd7c"
      "singlenic_ami" = "ami-0fb5db9d908d231c3"
      "lattiude"      = "26.10"
      "longitude"     = "50.46"
    }
    "sa-east-1"       = {
      "multinic_ami"  = "ami-07369c4b06cf22299"
      "singlenic_ami" = "ami-09082c4758ef6ec36"
      "lattiude"      = "-23.34"
      "longitude"     = "-46.38"
    }
    "af-south-1"       = {
      "multinic_ami"  = "ami-0c22728f79f714ed1"
      "singlenic_ami" = "ami-0bcfb554a48878b52"
      "lattiude"      = "-33.93"
      "longitude"     = "18.42"
    }
  }
}

variable "instance_type" {
  description = "OPTIONAL: The AWS instance type for the Customer Edge"
  type        = string
  default     = "t3.xlarge"
}

variable "instance_disk_size" {
  description = "OPTIONAL: The AWS disk size for the Customer Edge"
  type        = string
  default     = "80"
}
variable "sitelatitude" {
  description = "OPTIONAL: This will override the longitude lookup from the region, Site Physical Location Latitude. See https://www.latlong.net/"
  type        = string
  default     = ""
}
variable "sitelongitude" {
  description = "OPTIONAL: This will override the longitude lookup from the region, Site Physical Location Longitude. See https://www.latlong.net/"
  type        = string
  default     = ""
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