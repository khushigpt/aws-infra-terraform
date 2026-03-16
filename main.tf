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

  tags = {
    Name = "${var.project_name}-instance"
    Environment = var.environment
    ManagedBy = "Terraform"
}
}
