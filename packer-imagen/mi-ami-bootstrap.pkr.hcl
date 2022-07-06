# data "aws_ami" "os_ubuntu" {
#   owners      = ["099720109477"] #Canonical - Empresa que hace Ubuntu
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }
# }

data "amazon-ami" "ubuntu_22_04" {
  owners      = ["099720109477"]
  most_recent = true

  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
  }
}

source "amazon-ebs" "mi-ubuntu-personalizada" {
  region        =  "eu-west-3"
  source_ami    =  data.amazon-ami.ubuntu_22_04.id
  instance_type =  "t2.micro"
  ssh_username  =  "ubuntu"
  communicator  = "ssh"
  ami_name      =  "bootstrap_packer_ami_{{timestamp}}"
  tags = {
      Name = "mi-super-ami"
      OS_Version = "Ubuntu"
      Release = "Latest"
      Base_AMI_Name = "{{ .SourceAMIName }}"
      Creacion_AMI = "{{ .SourceAMICreationDate}}"
  }
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 40
    volume_type = "gp3"
    delete_on_termination = true
  }
}

build {
  sources = ["source.amazon-ebs.mi-ubuntu-personalizada"]

  provisioner "shell" {
    script = "bootstrap.sh"
  }
}