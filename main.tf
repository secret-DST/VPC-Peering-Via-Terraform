
resource "aws_vpc" "primary" {
  provider   = aws.primary
  cidr_block = var.vpc_cidrs[0]

  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name   = "Primary VPC"
    Region = "VPC in ${var.primary_region}"
  }
}

resource "aws_vpc" "secondary" {
  provider   = aws.secondary
  cidr_block = var.vpc_cidrs[1]

  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name   = "Secondary VPC"
    Region = "VPC in ${var.secondary_region}"
  }
}

# SUBNETS

resource "aws_subnet" "primary" {
  provider = aws.primary

  availability_zone = data.aws_availability_zones.primary.names[0]
  cidr_block        = var.subnet_cidrs[0]
  vpc_id            = aws_vpc.primary.id

  map_public_ip_on_launch = true

  tags = {
    Name = "Primary Subnet in ${var.primary_region}"
  }
}

resource "aws_subnet" "secondary" {
  provider = aws.secondary

  availability_zone = data.aws_availability_zones.secondary.names[0]
  cidr_block        = var.subnet_cidrs[1]
  vpc_id            = aws_vpc.secondary.id

  map_public_ip_on_launch = true

  tags = {
    Name = "Secondary Subnet in ${var.secondary_region}"
  }
}

# INTERNET GATEWAYS

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id

  tags = {
    Name = "primary-igw"
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id

  tags = {
    Name = "secondary-igw"
  }
}

# ROUTE TABLES

resource "aws_route_table" "primary_rt" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id

  tags = {
    Name = "Primary Route Table"
  }
}

resource "aws_route_table" "secondary_rt" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id

  tags = {
    Name = "Secondary Route Table"
  }
}

# ROUTE TABLE ASSOCIATIONS

resource "aws_route_table_association" "primary" {
  provider = aws.primary

  subnet_id      = aws_subnet.primary.id
  route_table_id = aws_route_table.primary_rt.id
}

resource "aws_route_table_association" "secondary" {
  provider = aws.secondary

  subnet_id      = aws_subnet.secondary.id
  route_table_id = aws_route_table.secondary_rt.id
}

# VPC PEERING

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider = aws.primary

  vpc_id      = aws_vpc.primary.id
  peer_vpc_id = aws_vpc.secondary.id
  peer_region = var.secondary_region
  auto_accept = false

  tags = {
    Name = "Primary peering to Secondary Peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "secondary_accepter" {
  provider = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true

  tags = {
    Name = "Secondary peering Accepter"
  }
}

# INTERNET ROUTES

resource "aws_route" "primary_internet" {
  provider = aws.primary

  route_table_id         = aws_route_table.primary_rt.id
  destination_cidr_block = var.all_traffic
  gateway_id             = aws_internet_gateway.primary_igw.id
}

resource "aws_route" "secondary_internet" {
  provider = aws.secondary

  route_table_id         = aws_route_table.secondary_rt.id
  destination_cidr_block = var.all_traffic
  gateway_id             = aws_internet_gateway.secondary_igw.id
}

# VPC PEERING ROUTES

resource "aws_route" "primary_to_secondary" {
  provider = aws.primary

  route_table_id            = aws_route_table.primary_rt.id
  destination_cidr_block    = var.vpc_cidrs[1]
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [
    aws_vpc_peering_connection_accepter.secondary_accepter
  ]
}

resource "aws_route" "secondary_to_primary" {
  provider = aws.secondary

  route_table_id            = aws_route_table.secondary_rt.id
  destination_cidr_block    = var.vpc_cidrs[0]
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [
    aws_vpc_peering_connection_accepter.secondary_accepter
  ]
}

resource "aws_key_pair" "primary" {
  provider = aws.primary

  key_name   = "primary-ec2-key"
  public_key = file(pathexpand(var.primary_public_key_path))

  tags = {
    Name = "Primary-EC2-SSH-Key"
  }
}

resource "aws_key_pair" "secondary" {
  provider = aws.secondary

  key_name   = "secondary-ec2-key"
  public_key = file(pathexpand(var.secondary_public_key_path))

  tags = {
    Name = "Secondary-EC2-SSH-Key"
  }
}

resource "aws_security_group" "primary" {
  provider = aws.primary

  name        = "primary-ec2-sg"
  description = "SSH from administrator and ICMP from secondary VPC"
  vpc_id      = aws_vpc.primary.id

  ingress {
    description = "SSH from administrator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Ping from secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidrs[1]]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Primary-EC2-SG"
  }
}

resource "aws_security_group" "secondary" {
  provider = aws.secondary

  name        = "secondary-ec2-sg"
  description = "SSH from administrator and ICMP from primary VPC"
  vpc_id      = aws_vpc.secondary.id

  ingress {
    description = "SSH from administrator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "Ping from primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidrs[0]]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Secondary-EC2-SG"
  }
}

resource "aws_instance" "primary" {
  provider = aws.primary

  ami                         = data.aws_ami.primary.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.primary.id
  key_name                    = aws_key_pair.primary.key_name
  vpc_security_group_ids      = [aws_security_group.primary.id]
  associate_public_ip_address = true

  private_ip = cidrhost(var.subnet_cidrs[0], 10)

  tags = {
    Name = "Primary-Ubuntu-EC2"
  }

  depends_on = [
    aws_route.primary_internet,
    aws_route.primary_to_secondary
  ]
}

resource "aws_instance" "secondary" {
  provider = aws.secondary

  ami                         = data.aws_ami.secondary.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.secondary.id
  key_name                    = aws_key_pair.secondary.key_name
  vpc_security_group_ids      = [aws_security_group.secondary.id]
  associate_public_ip_address = true

  private_ip = cidrhost(var.subnet_cidrs[1], 10)

  tags = {
    Name = "Secondary-Ubuntu-EC2"
  }

  depends_on = [
    aws_route.secondary_internet,
    aws_route.secondary_to_primary
  ]
}