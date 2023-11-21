resource "aws_instance" "ec2_instances" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance_size
  associate_public_ip_address = true
  root_block_device {
    volume_size = var.instance_root_device_size
    volume_type = "gp3"
  }
}