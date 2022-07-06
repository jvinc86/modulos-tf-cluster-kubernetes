resource "aws_vpc" "mi_vpc" {
  tags                 = { Name = "vpc-${var.NOMBRE_PROYECTO}" }
  cidr_block           = var.BLOQUE_CIDR_VPC
  enable_dns_hostnames = true
}

resource "aws_route_table" "mi_router" {
  tags   = { Name = "router-public-${var.NOMBRE_PROYECTO}" }
  vpc_id = aws_vpc.mi_vpc.id

  route {
    cidr_block = var.INTERNET
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_main_route_table_association" "asociar_router_principal_a_vpc" {
  vpc_id         = aws_vpc.mi_vpc.id
  route_table_id = aws_route_table.mi_router.id
  depends_on     = [aws_route_table.mi_router]
}

# resource "aws_network_acl_association" "asociar_acl_subred_privada" {
#   network_acl_id = aws_network_acl.firewall_subred_privada.id
#   subnet_id      = module.subred_privada.id_de_la_subred
# }

resource "aws_network_acl_association" "asociar_acl_subred_publica" {
  network_acl_id = aws_network_acl.firewall_subred_publica.id
  subnet_id      = module.subred_publica.id_de_la_subred
}

resource "aws_internet_gateway" "gw" {
  tags   = { Name = "igw-${var.NOMBRE_PROYECTO}" }
  vpc_id = aws_vpc.mi_vpc.id
}




