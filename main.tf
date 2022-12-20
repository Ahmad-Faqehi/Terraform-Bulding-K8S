provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

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
    s3buckit_name = "k8s-${random_string.s3name.result}"
  }

  depends_on = [
    aws_s3_bucket.s3buckit,
    random_string.s3name
  ]
}

resource "aws_instance" "ec2_instance_msr" {
    ami = var.ami_id
    count = var.number_of_instances
    subnet_id = var.subnet_id
    instance_type = var.instance_type
    key_name = var.ami_key_pair_name
    associate_public_ip_address = true
    security_groups = [ var.security_groups ]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
    tags = {
        Name = "K8S_msr"
    }
    user_data_base64       = base64encode(data.template_file.envMsr.rendered)
} 

resource "aws_instance" "ec2_instance_wrk" {
    ami = var.ami_id
    count = var.number_of_instances
    subnet_id = var.subnet_id
    instance_type = var.instance_type
    key_name = var.ami_key_pair_name
    associate_public_ip_address = true
    security_groups = [ var.security_groups ]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
    tags = {
        Name = "K8S_wrk"
    }
    user_data_base64       = base64encode(data.template_file.envWrk.rendered)
    depends_on = [
    aws_instance.ec2_instance_msr
  ]
} 