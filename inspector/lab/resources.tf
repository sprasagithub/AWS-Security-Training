
resource "random_string" "random_name" {
  length = 10
  special = false
  upper = false
}

resource "tls_private_key" "inspector_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "we45_aws_inspector-${random_string.random_name.result}"
  public_key = "${tls_private_key.inspector_key.public_key_openssh}"
}

resource "local_file" "aws_key" {
  content = "${tls_private_key.inspector_key.private_key_pem}"
  filename = "we45_aws_inspector.pem"
}


resource "aws_instance" "inspector" {

  tags {
    Name = "aws-inspector-instance-${random_string.random_name.result}"
  }
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name   = "${aws_key_pair.generated_key.key_name}"
  security_groups = [
  	"${aws_security_group.allow_ssh.name}"
  ]

  provisioner "remote-exec" {
  	connection {
  		type = "ssh"
  		user = "ubuntu"
  		private_key = "${tls_private_key.inspector_key.private_key_pem}"
  		host = "${aws_instance.inspector.public_ip}"
  	}
  	inline = [
  		"cd /tmp && curl -O https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install",
        "sudo bash /tmp/install",
  	]
  }
}










