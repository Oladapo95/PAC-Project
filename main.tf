# Create VPC
resource "aws_vpc" "pacpet1_vpc" {
  cidr_block = var.aws_vpc

  tags = {
    Name = "pacpet1_vpc"
  }
}

##2 Public Subnets
# Public Subnet 1
resource "aws_subnet" "pacpet1_pubsn_01" {
  vpc_id            = aws_vpc.pacpet1_vpc.id
  cidr_block        = var.aws_pubsub01
  availability_zone = "eu-west-2a"
  tags = {
    Name = "pacpet1_pubsn_01"
  }
}

# Public Subnet 2
resource "aws_subnet" "pacpet1_pubsn_02" {
  vpc_id            = aws_vpc.pacpet1_vpc.id
  cidr_block        = var.aws_pubsub02
  availability_zone = "eu-west-2b"
  tags = {
    Name = "pacpet1_pubsn_02"
  }
}

##2 Private Subnets
# Private Subnet 1
resource "aws_subnet" "pacpet1_prvsn_01" {
  vpc_id            = aws_vpc.pacpet1_vpc.id
  cidr_block        = var.aws_prvsub01
  availability_zone = "eu-west-2a"
  tags = {
    Name = "pacpet1_prvsn_01"
  }
}

#Private Subnet 2
resource "aws_subnet" "pacpet1_prvsn_02" {
  vpc_id            = aws_vpc.pacpet1_vpc.id
  cidr_block        = var.aws_prvsub02
  availability_zone = "eu-west-2b"
  tags = {
    Name = "pacpet1_prvsn_02"
  }
}

# Internet Gateway (This already attaches igw to vpc)
resource "aws_internet_gateway" "pacpet1_igw" {
  vpc_id = aws_vpc.pacpet1_vpc.id

  tags = {
    Name = "pacpet1_igw"
  }
}

#Create Elastic IP for NAT gateway
resource "aws_eip" "pacpet1_nat_eip" {
  vpc = true
  tags = {
    Name = "pacpet1_nat_eip"
  }
}

# Create NAT gateway
resource "aws_nat_gateway" "pacpet1_ngw" {
  allocation_id = aws_eip.pacpet1_nat_eip.id
  subnet_id     = aws_subnet.pacpet1_pubsn_01.id

  tags = {
    Name = "pacpet1_ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.pacpet1_igw]
}

# Create Public Route Table
resource "aws_route_table" "pacpet1_igw_rt" {
  vpc_id = aws_vpc.pacpet1_vpc.id

  route {
    cidr_block = var.all_ip
    gateway_id = aws_internet_gateway.pacpet1_igw.id
  }

  tags = {
    Name = "pacpet1_igw_rt"
  }
}

## Associate the two public subnets
# Route table association for public subnet 1
resource "aws_route_table_association" "pacpet1_pub1_rt" {
  subnet_id      = aws_subnet.pacpet1_pubsn_01.id
  route_table_id = aws_route_table.pacpet1_igw_rt.id
}

# Route table association for public subnet 2
resource "aws_route_table_association" "pacpet1_pub2_rt" {
  subnet_id      = aws_subnet.pacpet1_pubsn_02.id
  route_table_id = aws_route_table.pacpet1_igw_rt.id
}

# Create Private Route Table
resource "aws_route_table" "pacpet1_ngw_rt" {
  vpc_id = aws_vpc.pacpet1_vpc.id

  route {
    cidr_block = var.all_ip
    gateway_id = aws_nat_gateway.pacpet1_ngw.id
  }

  tags = {
    Name = "pacpet1_ngw_rt"
  }
}

## Associate the two private subnets
# Route table association for private subnet 1
resource "aws_route_table_association" "pacpet1_prv1_rt" {
  subnet_id      = aws_subnet.pacpet1_prvsn_01.id
  route_table_id = aws_route_table.pacpet1_ngw_rt.id
}

# Route table association for private subnet 2
resource "aws_route_table_association" "pacpet1_prv2_rt" {
  subnet_id      = aws_subnet.pacpet1_prvsn_02.id
  route_table_id = aws_route_table.pacpet1_ngw_rt.id
}

##Create Two security groups

#Security group for frontend servers (Allows http and ssh)
resource "aws_security_group" "pacpet1_frontend_sg" {
  name        = "pacpet1_frontend_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.pacpet1_vpc.id

  ingress {
    description = "Allow http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }
  ingress {
    description = "Allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip]
  }

  tags = {
    Name = "pacpet1_frontend_sg"
  }
}

#Security group for backend servers (Allows from frontend_sg)
resource "aws_security_group" "pacpet1_backend_sg" {
  name        = "pacpet1_backend_sg"
  description = "Allow traffic from frontend sg"
  vpc_id      = aws_vpc.pacpet1_vpc.id

  ingress {
    description = "Allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.aws_pubsub01}", "${var.aws_pubsub02}"]
  }

  ingress {
    description = "Allow mysql traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.aws_pubsub01}", "${var.aws_pubsub02}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pacpet1_backend_sg"
  }
}

#Creates a key pair resource
resource "aws_key_pair" "pacpet1_keyPair" {
  key_name   = var.key_name
  public_key = file(var.pacpet1_keypair_path)
}

#Create Ansible Server
resource "aws_instance" "pacpet1_ec2_instance" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.pacpet1_keyPair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pacpet1_pubsn_01.id
  vpc_security_group_ids      = ["${aws_security_group.pacpet1_frontend_sg.id}"]
  tags = {
    Name = "pacpet1_ec2_instance"
  }
}



