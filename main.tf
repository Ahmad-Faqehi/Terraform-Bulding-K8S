provider "aws" {
  region     = "us-east-1"
  access_key = "<Put_Your_Key>"
  secret_key = "<Put_Your_Key>"
}

resource "aws_instance" "ec2_instance_msr" {
    ami = "${var.ami_id}"
    count = "${var.number_of_instances}"
    subnet_id = "${var.subnet_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.ami_key_pair_name}"
    associate_public_ip_address = true
    security_groups = [ "${var.security_groups}" ]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
    tags = {
        Name = "K8S_msr"
    }
    user_data = "${file("scripts/install_k8s_msr.sh")}"
} 

resource "aws_instance" "ec2_instance_wrk" {
    ami = "${var.ami_id}"
    count = "${var.number_of_instances}"
    subnet_id = "${var.subnet_id}"
    instance_type = "${var.instance_type}"
    key_name = "${var.ami_key_pair_name}"
    associate_public_ip_address = true
    security_groups = [ "${var.security_groups}" ]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
    tags = {
        Name = "K8S_wrk"
    }
    user_data = "${file("scripts/install_k8s_wrk.sh")}"
    depends_on = [
    aws_instance.ec2_instance_msr
  ]
} 