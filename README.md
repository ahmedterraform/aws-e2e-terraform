# AWS VPC (Public/Private Subnets) + NAT Gateway using Terraform

This repository demonstrates how to build a production-style AWS networking baseline using Terraform:
- Public subnets for internet-facing components
- Private subnets for internal workloads (no public IPs)
- NAT Gateway to allow private subnets outbound internet access securely

## Architecture
- VPC
- Internet Gateway (IGW)
- 2 Public Subnets (across 2 AZs)
- 2 Private Subnets (across 2 AZs)
- Elastic IP + NAT Gateway (in Public Subnet)
- Public Route Table (0.0.0.0/0 -> IGW)
- Private Route Table (0.0.0.0/0 -> NAT)

## Why this matters
This setup is a common baseline for production AWS environments:
- Better security (private workloads are not exposed directly)
- High availability (multi-AZ subnets)
- Cleaner routing & separation of concerns

## Prerequisites
- Terraform installed
- AWS CLI configured (`aws configure`)
- An AWS account with permissions to create VPC resources

## How to Run
```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
