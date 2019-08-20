# AWS Config

variable "aws_region" {
  default = "us-east-1"
}

variable "ec2_ami_id" {
  default = "ami-0cfee17793b08a293"
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "aws_credential_path" {
  default = "~/.aws/tf_admin_acces.csv"
}

# SSH keys, user
variable "ssh_pub_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGyEPTIRkjs8WH1bJ4mN/eC8/sB02Yfy3d9u5WAbOIt4U3hemTg6ASuY/72vi9nagKZDFc+2Vny8fBBbWEZ4bfqcmVT81cw8etgv6KqFB6xcwcWL1JCeZvm6wHuDUPWMZBx+zGvOtHMS96sxFvRPPV8SyO7ALLsFnvfhKONZckbEK6x9sdHAh6ph+Hz3JZMXadTKcJmK/68uMCH4h2mWDGwwoLJBWm9QPtjfei+9C3dGJ0OH3xGxsgdsov26+5s4z2ADuoc5zkBJdc6WLmYj5P1YGSRiAFwRR3H0fjHq1nC52In3JHgGMJuXRBl8l2vlGloQI8XBPXuUIQO+j5Fzyh ash@ansh-work" 
}

variable "ssh_priv_key_path" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_user" {
  default = "ubuntu"
}

# Ansible playbook
variable "ansible_provision_playbook" {
  default = "install-web-server.yaml"
}

# s3
variable "s3_bucket" {
  default = "web-server-content-23-08-19"
}

variable "s3_object" {
  default = "index.html"
}

variable "s3_file_to_upload" {
  default = "terraform_files/index.html"
}
