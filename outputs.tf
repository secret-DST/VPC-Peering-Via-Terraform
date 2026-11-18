output "primary_ec2_public_ip" {
  description = "Primary EC2 public IP"
  value       = aws_instance.primary.public_ip
}

output "primary_ec2_private_ip" {
  description = "Primary EC2 private IP"
  value       = aws_instance.primary.private_ip
}

output "secondary_ec2_public_ip" {
  description = "Secondary EC2 public IP"
  value       = aws_instance.secondary.public_ip
}

output "secondary_ec2_private_ip" {
  description = "Secondary EC2 private IP"
  value       = aws_instance.secondary.private_ip
}

output "vpc_peering_connection_id" {
  description = "Cross-region VPC peering connection ID"
  value       = aws_vpc_peering_connection.primary_to_secondary.id
}

output "primary_ssh_command" {
  value = "ssh -i ~/.ssh/aws-primary ubuntu@${aws_instance.primary.public_ip}"
}

output "secondary_ssh_command" {
  value = "ssh -i ~/.ssh/aws-secondary ubuntu@${aws_instance.secondary.public_ip}"
}