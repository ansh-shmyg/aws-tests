provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}


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

resource "aws_instance" "web-server-01" {
  ami = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"
  key_name = "terraform_ec2_key"
  
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
