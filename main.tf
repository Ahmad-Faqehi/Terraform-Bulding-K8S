provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
#****** VPC Start ******#

resource "aws_vpc" "some_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "K8S VPC"
  }
}

resource "aws_subnet" "some_public_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "K8S Subnet"
  }
}

resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.some_custom_vpc.id

  tags = {
    Name = "K8S Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.some_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.some_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "k8s_sg" {
  name   = "K8S Ports"
  vpc_id = aws_vpc.some_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#****** VPC END ******#

resource "random_string" "s3name" {
  length = 9
  special = false
  upper = false
  lower = true
}

resource "aws_s3_bucket" "s3buckit" {
  bucket = "k8s-${random_string.s3name.result}"
  force_destroy = true
 depends_on = [
    random_string.s3name
  ]
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.s3buckit.id
  acl    = "private"
}

data "template_file" "envMsr" {
  template = file("scripts/install_k8s_msr.sh")
  vars = {
    access_key = var.access_key,
    private_key = var.secret_key,
    region = var.region,
    s3buckit_name = "k8s-${random_string.s3name.result}"
  }

  depends_on = [
    aws_s3_bucket.s3buckit,
    random_string.s3name
  ]
}

data "template_file" "envWrk" {
  template = file("scripts/install_k8s_wrk.sh")
  vars = {
    access_key = var.access_key,
    private_key = var.secret_key,
    region = var.region,
    s3buckit_name = "k8s-${random_string.s3name.result}"
  }

  depends_on = [
    aws_s3_bucket.s3buckit,
    random_string.s3name
  ]
}

resource "aws_instance" "ec2_instance_msr" {
    ami = var.ami_id
    #count = var.number_of_instances
    # subnet_id = var.subnet_id
    subnet_id = aws_subnet.some_public_subnet.id
    instance_type = var.instance_type
    key_name = var.ami_key_pair_name
    associate_public_ip_address = true
    # security_groups = [ var.security_groups ]
    security_groups = [ aws_security_group.k8s_sg.id ]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
    tags = {
        Name = "k8s_msr"
    }
    user_data_base64       = base64encode(data.template_file.envMsr.rendered)
} 

resource "aws_instance" "ec2_instance_wrk" {
    ami = var.ami_id
    count = var.number_of_worker
    subnet_id = aws_subnet.some_public_subnet.id
    # subnet_id = var.subnet_id
    instance_type = var.instance_type
    key_name = var.ami_key_pair_name
    associate_public_ip_address = true
    security_groups = [ aws_security_group.k8s_sg.id ]
    # security_groups = [ var.security_groups ]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
    tags = {
        Name = "k8r_wrk_${count.index + 1}"
    }
    user_data_base64       = base64encode(data.template_file.envWrk.rendered)
    depends_on = [
    aws_instance.ec2_instance_msr
  ]
} 