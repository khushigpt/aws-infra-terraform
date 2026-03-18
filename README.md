# AWS Infrastructure Automation with Terraform

Production-grade AWS Infrastructure provisioned entirely through Terrafrom IaC - eliminating manual setup and enabling consistent repeatable deployments

## Architecture
```
Internet
    |
Internet Gateway
    |
VPC (10.0.0.0/16)
    |
Public Subnet (10.0.1.0/24)  ←  Route Table (0.0.0.0/0 → IGW)
    |
EC2 Instance (t2.micro)
    |
Security Group (port 22 restricted to specific IP)
```

## Infrastructure Components

| Resource | Purpose |
| --- | --- |
| VPC | Isolated private network with DNS enabled |
| Internet Gateway | Entry point between VPC and internet |
| Public Subnet | EC2 hosting subnet in ap-south-1a |
| Route Table | Routes internet traffic through IGW |
| Security Group | Restricts SSH to specific IP only |
| EC2 Instance | Amazon Linux 2, t2.micro (free tier) |
| S3 Backend | Remote state storage with versioning enabled |
| IAM Role            | EC2 identity with S3 read access
| IAM Policy          | Least-privilege S3 read permissions  
| Instance Profile    | Attaches IAM role to EC2

## Key Design Decisions

**Remote state in S3** - State stored in S3 with versioning enabled 
so the entire team shares the same infrastructure view and state 
history is preserved for rollback.

**SSH restricted by IP** — Port 22 is not open to 0.0.0.0/0. 
In production, SSH is restricted to a specific IP or removed 
entirely in favour of AWS Systems Manager Session Manager.

**Everything tagged** — All resources tagged with Name, Environment, 
and ManagedBy=Terraform for cost tracking and audit purposes.

**Modular variables** — All configurable values in variables.tf 
so the same code deploys to dev, staging, and production by 
passing different tfvars files.

## How to Run

**Prerequisites:** Terraform >= 1.0, AWS CLI configured,
S3 bucket for state
```bash
# Initialise
terraform init

# Review what will be created
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy when done (avoid unnecessary AWS costs)
terraform destroy
```

## What I Learned

- How Terraform manages infrastructure state and dependency ordering
- VPC networking — IGW, subnets, route tables, security groups
- Why `terraform plan -out=tfplan` is critical before any apply
- How `-/+` replace differs from `~` in-place modification
- SSH key pair management and EC2 access patterns
- Remote state management and why local state is dangerous in teams

## Security Note

This project uses `t2.micro` which is AWS free tier eligible.
Always run `terraform destroy` after learning sessions to avoid
unexpected charges.
