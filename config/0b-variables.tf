variable "NOMBRE_PROYECTO" { default = "neo" }
variable "TIPO_INSTANCIA" { default = "t2.micro" }
variable "BLOQUE_CIDR_VPC" { default = "10.0.0.0/16" }
variable "BLOQUE_CIDR_SUBRED_PUBLIC" { default = "10.0.150.0/24" }
variable "BLOQUE_CIDR_SUBRED_PRIVATE" { default = "10.0.0.0/24" }
variable "INTERNET" { default = "0.0.0.0/0" }
variable "AV_ZONES" {
  type = map(string)
  default = {
    a = "eu-west-3a"
    b = "eu-west-3b"
    c = "eu-west-3c"
  }
}
variable "IP_SERVIDOR_GUARDIAN" { default = "10.0.150.10" }


# ------------ Firewall Privado ----------------
locals {
  reglas_ENTRADA_fw_privado = [
    { protocolo = "tcp", bloque_cidr = [], resumen = "Acceso SSH desde Firewall Publico", puerto = 22, yo_mismo = false, sg_ids = [module.firewall_ec2_publico.id_de_sg] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto HTTP", puerto = 80, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto HTTPS", puerto = 443, yo_mismo = false, sg_ids = [] },
    { protocolo = "icmp", bloque_cidr = [], resumen = "PING desde Firewall Publico", puerto = -1, yo_mismo = false, sg_ids = [module.firewall_ec2_publico.id_de_sg] }
  ]
}

locals {
  reglas_SALIDA_fw_privado = [
    { protocolo = -1, bloque_cidr = [], resumen = "Salida hacia Firewall Publico", puerto = 0, yo_mismo = false, sg_ids = [module.firewall_ec2_publico.id_de_sg] }
  ]
}

# ------------ Firewall Publico ----------------
locals {
  reglas_ENTRADA_fw_publico = [
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto SSH", puerto = 22, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto HTTP", puerto = 80, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto HTTPS", puerto = 443, yo_mismo = false, sg_ids = [] },

    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto Calico Networking", puerto = 179, yo_mismo = false, sg_ids = [] },
    { protocolo = "udp", bloque_cidr = [var.INTERNET], resumen = "Puerto Calico Networking", puerto = 4789, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto Calico Networking", puerto = 5473, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto Calico Networking", puerto = 2379, yo_mismo = false, sg_ids = [] },

    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto Weave Net", puerto = 6783, yo_mismo = false, sg_ids = [] },
    { protocolo = "udp", bloque_cidr = [var.INTERNET], resumen = "Puerto Weave Net", puerto = 6783, yo_mismo = false, sg_ids = [] },
    { protocolo = "udp", bloque_cidr = [var.INTERNET], resumen = "Puerto Weave Net", puerto = 6784, yo_mismo = false, sg_ids = [] },

    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto K8s", puerto = 6443, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto K8s", puerto = 10250, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto K8s", puerto = 10259, yo_mismo = false, sg_ids = [] },
    { protocolo = "tcp", bloque_cidr = [var.INTERNET], resumen = "Puerto K8s", puerto = 10257, yo_mismo = false, sg_ids = [] },

    { protocolo = "icmp", bloque_cidr = [var.INTERNET], resumen = "PING desde Internet", puerto = -1, yo_mismo = false, sg_ids = [] },
    { protocolo = "icmp", bloque_cidr = [], resumen = "PING entre SUBREDES", puerto = -1, yo_mismo = true, sg_ids = [] }
  ]
}

locals {
  reglas_SALIDA_fw_publico = [
    { protocolo = -1, bloque_cidr = [var.INTERNET], resumen = "Salida Internet", puerto = 0, yo_mismo = false, sg_ids = [] }
  ]
}

