# F5XC AWS CE MULTINIC

Terraform to create F5XC AWS cloud Ingress Egress Customer Edge (CE) 3 node cluster

## Usage

- Clone this repo with: `git clone https://github.com/aconley245/f5xc-aws-ce-multinic`
- Enter repository directory with: `cd f5xc-aws-ce-multinic`
- Input values for the variables by creating a terraform.tfvars file or enter values when prompted during apply
- CE's must be deployed using programatic access (Access Key and Secret Access Key).  AWS Security Token Service (STS) will not work.
- Initialize with: `terraform init`
- Apply with: `terraform apply` or destroy with: `terraform destroy`

