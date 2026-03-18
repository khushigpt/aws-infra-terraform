resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "${var.project_name}-vpc"
    Environment = var.environment
    ManagedBy = "Terraform"
}
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
    Environment = var.environment
    ManagedBy = "Terraform"
}
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
    Environment = var.environment
    ManagedBy = "Terraform"
}
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-route-table"
    Environment = var.environment
    ManagedBy = "Terraform"
}
}

resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "main" {
  name = "${var.project_name}-sg"
  description = "Security Group for vpc ${aws_vpc.main.id}"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH access"
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" #means all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
   }

   tags = {
    Name = "${var.project_name}-security-group"
    Environment = var.environment
    ManagedBy = "Terraform"
}
}

resource "aws_key_pair" "main" {
  key_name = "${var.project_name}-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "main" {
  ami = "ami-0f58b397bc5c1f2e8"
  instance_type = var.instance_type
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name = aws_key_pair.main.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-instance"
    Environment = var.environment
    ManagedBy = "Terraform"
}
}

#the role itself (includes trust policy)
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
    Environment = var.environment
    ManagedBy = "Terraform"
  }
}

#the permission policy (what it can do)
resource "aws_iam_policy" "ec2_s3_policy" {
  name = "${var.project_name}-ec2-s3-policy"
  description = "Allow EC2 to read from state bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::khushi-terraform-state-2026",
          "arn:aws:s3:::khushi-terraform-state-2026/*"
        ]
      }
    ]
  })
}

#policy attachment links policy to role
resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  role = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

#instance profile wraps role for ec2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
