variable nombre_proyecto { default = "" }
variable tipo_fw { default = "" }
variable la_vpc { default = "" }
variable descripcion { default = "" }
variable r_entrada {
    type    = list(any)
    default = []
}
variable r_salida {
    type    = list(any)
    default = []
}

resource "aws_security_group" "firewall_ec2" {
  tags        = { Name = "sg-${var.tipo_fw}-${var.nombre_proyecto}" }
  name        = "${var.nombre_proyecto}-sg-${var.tipo_fw}"
  vpc_id      = var.la_vpc
  description = var.descripcion

  dynamic "ingress" {
    for_each = var.r_entrada

    content {
      protocol        = ingress.value["protocolo"]
      cidr_blocks     = ingress.value["bloque_cidr"]
      description     = ingress.value["resumen"]
      from_port       = ingress.value["puerto"]
      to_port         = ingress.value["puerto"]
      self            = ingress.value["yo_mismo"]
      security_groups = ingress.value["sg_ids"]
    }
  }

  ingress {
    description      = "K8s Rango Master"
    from_port        = 2379
    to_port          = 2380
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "K8s Rango Workers"
    from_port        = 30000
    to_port          = 32767
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  dynamic "egress" {
    for_each = var.r_salida

    content {
      protocol        = egress.value["protocolo"]
      cidr_blocks     = egress.value["bloque_cidr"]
      description     = egress.value["resumen"]
      from_port       = egress.value["puerto"]
      to_port         = egress.value["puerto"]
      self            = egress.value["yo_mismo"]
      security_groups = egress.value["sg_ids"]
    }
  }

}

output id_de_sg {
  value = aws_security_group.firewall_ec2.id
}
