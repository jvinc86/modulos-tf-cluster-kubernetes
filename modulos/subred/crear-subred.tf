variable tipo_red { default = "" }
variable letra_az { default = ""}
variable la_vpc { default = ""}
variable bloque_subred_cidr { default = ""}
variable proyecto { default = ""}
variable mapa_tres_av_zones {
    type = map(string)
    default = {}
}

resource "aws_subnet" "subred" {
  tags                    = { Name = "subred-${var.tipo_red}-${var.proyecto}" }
  vpc_id                  = var.la_vpc
  cidr_block              = var.bloque_subred_cidr
  map_public_ip_on_launch = var.tipo_red == "publica" ? true : false
  availability_zone       = var.mapa_tres_av_zones[var.letra_az]
}

output id_de_la_subred {
  value = aws_subnet.subred.id
}

