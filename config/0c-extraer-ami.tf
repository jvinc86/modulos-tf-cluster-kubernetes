# data "aws_ami" "os_ubuntu" {
#   owners      = ["099720109477"] #Canonical - Empresa que hace Ubuntu
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }
# }

data "aws_ami" "os_ubuntu" {
  owners      = ["self"]
  most_recent = true
  name_regex  = "^bootstrap_packer_ami_.*"
}