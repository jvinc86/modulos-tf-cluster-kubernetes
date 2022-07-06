resource "aws_key_pair" "llave-ssh-neo" {
  key_name   = "llave-ssh-${var.NOMBRE_PROYECTO}"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_network_acl" "firewall_subred_publica" {
  tags       = { Name = "acl-publico-${var.NOMBRE_PROYECTO}" }
  subnet_ids = [module.subred_publica.id_de_la_subred]
  vpc_id     = aws_vpc.mi_vpc.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.INTERNET
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = var.INTERNET
    from_port  = 0
    to_port    = 0
  }

}

# resource "aws_network_acl" "firewall_subred_privada" {
#   tags       = { Name = "acl-privado-${var.NOMBRE_PROYECTO}" }
#   subnet_ids = [module.subred_privada.id_de_la_subred]
#   vpc_id     = aws_vpc.mi_vpc.id

#   ingress {
#     protocol   = -1
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = var.INTERNET
#     from_port  = 0
#     to_port    = 0
#   }

#   egress {
#     protocol   = -1
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = var.INTERNET
#     from_port  = 0
#     to_port    = 0
#   }

# }