output "instance_ip_addr" {
  value = aws_instance.web-server-01.public_ip
  description = "the public IP of aws instance"
}

