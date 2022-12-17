# variable "access_key" {
#         description = "Access key to AWS console"
# }
# variable "secret_key" {
#         description = "Secret key to AWS console"
# }


variable "instance_name" {
        description = "Name of the instance to be created"
        default = "k8s"
}

variable "instance_type" {
        default = "t2.medium"
}

variable "subnet_id" {
        description = "The VPC subnet the instance(s) will be created in"
        # default = "subnet-07ebbe60"
        default = "subnet-bbccdcf6"
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0a6b2839d44d781b2"
}

variable "security_groups" {
        description = "The Security Groups to use"
        default = "sg-0bc18994e9d9dcfd3"
}

variable "number_of_instances" {
        description = "number of instances to be created"
        default = 1
}


variable "ami_key_pair_name" {
        default = "AhmadKey"
}