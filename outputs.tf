output "instance_msr_public_ip" {
  description = "Public address IP of master"
  value       = aws_instance.ec2_instance_msr.public_ip
}

output "instance_wrks_public_ip" {
  description = "Public address IP of worker"
  value       = aws_instance.ec2_instance_wrk.*.public_ip
}

# output "instance_msr_privte_ip" {
#   description = "Private IP address of master"
#   value       = aws_instance.ec2_instance_msr.private_ip
# }

# output "s3_bucket_name" {
#   description = "The S3 bucket name"
#   value       = "k8s-${random_string.s3name.result}"
# }
