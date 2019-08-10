# Set provider
provider "aws" {
  shared_credentials_file = "${file(var.aws_credential_path)}"
  region = "${var.aws_region}"
}

# IAM roles, policies
resource "aws_iam_role" "s3_read_role" {
  name               = "tf_s3_read_role"
  description = "S3 read access. Role"
  assume_role_policy = "${file("terraform_files/aws_assumerolepolicy.json")}"
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "tf_s3_read_policy"
  description = "S3 read access. Policy"
  policy      = "${file("terraform_files/aws_policy_s3_read.json")}"
}

resource "aws_iam_policy_attachment" "attach_s3_read_policy" {
  name       = "attach_s3_read"
  roles      = ["${aws_iam_role.s3_read_role.name}"]
  policy_arn = "${aws_iam_policy.s3_read_policy.arn}"
}

# network ACL
resource "aws_security_group" "allow_ports_web_server" {
  name        = "allow_http_ssh_icpm"
  description = "Allow SSH, HTTP, TLS, ICMP inbound traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_22_80_443_icmp"
  }
}

# EC2 VPS creation, configuration
resource "aws_iam_instance_profile" "s3_read_profile" {
  name = "s3_read"
  role = "${aws_iam_role.s3_read_role.name}"
}

resource "aws_instance" "web-server-01" {
  ami = "${var.ec2_ami_id}"
  instance_type = "${var.ec2_instance_type}"
  key_name = "terraform_ec2_key"
  iam_instance_profile = "${aws_iam_instance_profile.s3_read_profile.name}"
  
  tags = {
    Name = "web-server-01"
  }

}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = "${aws_security_group.allow_ports_web_server.id}"
  network_interface_id = "${aws_instance.web-server-01.primary_network_interface_id}"
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name = "terraform_ec2_key"
  public_key = "${var.ssh_pub_key}"
}

# Upload index.html file to s3
resource "aws_s3_bucket_object" "s3_object" {
  bucket = "${var.s3_bucket}"
  key    = "${var.s3_object}"
  source = "${var.s3_file_to_upload}"
}

# Post-creation commands. Install python2, run Ansible playbook
resource "null_resource" "run_ssh_command" {
  provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y python-minimal"
  ]
  connection {
    type        = "ssh"
    host        = "${aws_instance.web-server-01.public_ip}"
    private_key = "${file(var.ssh_priv_key_path)}"
    user        = "${var.ssh_user}"
  }  
}
  depends_on = ["aws_network_interface_sg_attachment.sg_attachment"]
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -u '${var.ssh_user}' --private-key '${var.ssh_priv_key_path}' -i ',${aws_instance.web-server-01.public_ip}' '${var.ansible_provision_playbook}'"
  }
  depends_on = ["null_resource.run_ssh_command"]
}
