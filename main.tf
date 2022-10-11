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


#Security group for Jenkins
resource "aws_security_group" "pacpet1_jenkins_sg" {
  name        = "pacpet1_jenkins_sg"
  description = "Allow Jenkins traffic"
  vpc_id      = aws_vpc.pacpet1_vpc.id

  ingress {
    description = "Port traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

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
    Name = "pacpet1_jenkins_sg"
  }
}

#Security group for Ansible
resource "aws_security_group" "pacpet1_ansible_sg" {
  name        = "pacpet1_ansible_sg"
  description = "Allow traffic for ssh"
  vpc_id      = aws_vpc.pacpet1_vpc.id

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pacpet1_ansible_sg"
  }
}

#Security group for Docker Servers
resource "aws_security_group" "pacpet1_docker_sg" {
  name        = "pacpet1_docker_sg"
  description = "Allow traffic for ssh"
  vpc_id      = aws_vpc.pacpet1_vpc.id

  ingress {
    description = "Allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  ingress {
    description = "Allow Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pacpet1_docker_sg"
  }
}

#Security group for Mysql
resource "aws_security_group" "pacpet1_mysql_sg" {
  name        = "pacpet1_mysql_sg"
  description = "Allow traffic for mysql"
  vpc_id      = aws_vpc.pacpet1_vpc.id

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
    Name = "pacpet1_mysql_sg"
  }
}

#Security group for SonarQube
resource "aws_security_group" "pacpet1_sonarqube_sg" {
  name        = "pacpet1_sonarqube_sg"
  description = "Allow traffic for SonarQube"
  vpc_id      = aws_vpc.pacpet1_vpc.id

  ingress {
    description = "Allow Sonar traffic"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }
  ingress {
    description = "Allow traffic on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pacpet1_sonarqube_sg"
  }
}

# #Creates a key pair resource
# resource "aws_key_pair" "pacpet1_keyPair" {
#   key_name   = var.key_name
#   public_key = file(var.pacpet1_pubkey_path)
# }

#Create Ansible Server
resource "aws_instance" "pacpet1_ansible" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.micro"
  key_name                    = "pacpet1-key"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pacpet1_pubsn_01.id
  vpc_security_group_ids      = ["${aws_security_group.pacpet1_ansible_sg.id}"]
  user_data                   = local.ansible_user_data
  tags = {
    Name = "pacpet1_ansible"
  }
}

#Create Docker Server
resource "aws_instance" "pacpet1_docker" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.micro"
  key_name                    = "pacpet1-key"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pacpet1_pubsn_01.id
  vpc_security_group_ids      = ["${aws_security_group.pacpet1_docker_sg.id}"]
  user_data                   = local.docker_user_data
  tags = {
    Name = "pacpet1_docker"
  }
}

#Create Jenkins Server
resource "aws_instance" "pacpet1_jenkins" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.medium"
  key_name                    = "pacpet1-key"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pacpet1_pubsn_01.id
  vpc_security_group_ids      = ["${aws_security_group.pacpet1_jenkins_sg.id}"]
  user_data                   = local.jenkins_user_data
  tags = {
    Name = "pacpet1_jenkins"
  }
}

#Create SonarQube Server
resource "aws_instance" "pacpet1_sonarqube" {
  ami                         = "ami-0f540e9f488cfa27d"
  instance_type               = "t2.medium"
  key_name                    = "pacpet1-key"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pacpet1_pubsn_02.id
  vpc_security_group_ids      = ["${aws_security_group.pacpet1_sonarqube_sg.id}"]
  user_data                   = local.sonarqube_user_data
  tags = {
    Name = "pacpet1_sonarqube"
  }
}

resource "time_sleep" "wait_for_jenkins" {
  depends_on = [aws_instance.pacpet1_jenkins]
  create_duration = "150s"
}

#Echo password to screen
resource "null_resource" "user_data_status_y" {
  provisioner "local-exec" {
    on_failure  = fail
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
          ssh -o StrictHostKeyChecking=no -i pacpet1-key ubuntu@${aws_instance.pacpet1_jenkins.public_ip} "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
          if [ $? -eq 0 ]; then
          echo "user data sucessfully executed"
          else
            echo "Failed to execute user data"
          fi
     EOT
  }
    triggers = {
    #remove this once you test it out as it should run only once
    #always_run ="${timestamp()}"
  }
  depends_on = [time_sleep.wait_for_jenkins]

}


#Create AMI from EC2 Instance
resource "aws_ami_from_instance" "pacpet1_ami" {
  name               = "pacpet1_ami"
  source_instance_id = aws_instance.pacpet1_docker.id
}

##Add High Availability

#Create Target Group
resource "aws_lb_target_group" "pacpet1_tg" {
  name     = "pacpet1-TG"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.pacpet1_vpc.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

#Create Application Load Balancer
resource "aws_lb" "pacpet1_lb" {
  name               = "pacpet1-Lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.pacpet1_jenkins_sg.id}"]
  subnets            = ["${aws_subnet.pacpet1_pubsn_01.id}", "${aws_subnet.pacpet1_pubsn_02.id}"]

  enable_deletion_protection = false

  tags = {
    Name = "pacpet1-Lb"
  }
}

# Create Load Balancer Listener
resource "aws_lb_listener" "pacpet1-Lbl" {
  load_balancer_arn = aws_lb.pacpet1_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.pacpet1_tg.arn
    type             = "forward"
  }
}

#Create Launch Configuration
resource "aws_launch_configuration" "pacpet1_lc" {
  name_prefix                 = "pacpet1-lc-"
  image_id                    = aws_ami_from_instance.pacpet1_ami.id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.pacpet1_jenkins_sg.id}"]
  key_name                    = "pacpet1-key"
  lifecycle {
    create_before_destroy = true
  }
}

#Create Auto Scaling group
resource "aws_autoscaling_group" "pacpet1_asg" {
  name                 = "pacpet1-ASG"
  launch_configuration = aws_launch_configuration.pacpet1_lc.name
  #Defines the vpc, az and subnets to launch in
  vpc_zone_identifier       = ["${aws_subnet.pacpet1_pubsn_01.id}", "${aws_subnet.pacpet1_pubsn_02.id}"]
  target_group_arns         = ["${aws_lb_target_group.pacpet1_tg.arn}"]
  health_check_type         = "EC2"
  health_check_grace_period = 30
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  force_delete              = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "pacpet1_asg_policy" {
  name                   = "pacpet1_asg_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.pacpet1_asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}

#Create Hosted Zone
resource "aws_route53_zone" "pacpet1_hosted_zone" {
  name = "oladapoiyanda.com"
}

resource "aws_route53_record" "pacpd_record" {
  zone_id = aws_route53_zone.pacpet1_hosted_zone.zone_id
  name    = ""
  type    = "A"
  alias {
    name                   = aws_lb.pacpet1_lb.dns_name
    zone_id                = aws_lb.pacpet1_lb.zone_id
    evaluate_target_health = true
  }
}
