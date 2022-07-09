# --------------------- SUBREDES ---------------------
module "subred_publica" {
  source             = "../modulos/subred"
  tipo_red           = "publica"
  letra_az           = "b"
  la_vpc             = aws_vpc.mi_vpc.id
  bloque_subred_cidr = var.BLOQUE_CIDR_SUBRED_PUBLIC
  proyecto           = var.NOMBRE_PROYECTO
  mapa_tres_av_zones = var.AV_ZONES
}
# module "subred_privada" {
#   source             = "../modulos/subred"
#   tipo_red           = "privada"
#   letra_az           = "c"
#   la_vpc             = aws_vpc.mi_vpc.id
#   bloque_subred_cidr = var.BLOQUE_CIDR_SUBRED_PRIVATE
#   proyecto           = var.NOMBRE_PROYECTO
#   mapa_tres_av_zones = var.AV_ZONES
# }
# --------------------- FIREWALL ---------------------
# module "firewall_ec2_privado" {
#   source = "../modulos/sec_group"

#   nombre_proyecto = var.NOMBRE_PROYECTO
#   tipo_fw         = "privado"
#   la_vpc          = aws_vpc.mi_vpc.id
#   descripcion     = "Firewall Privado de las Instancias"
#   r_entrada       = local.reglas_ENTRADA_fw_privado
#   r_salida        = local.reglas_SALIDA_fw_privado
# }
module "firewall_ec2_publico" {
  source = "../modulos/sec_group"

  nombre_proyecto = var.NOMBRE_PROYECTO
  tipo_fw         = "publico"
  la_vpc          = aws_vpc.mi_vpc.id
  descripcion     = "Firewall Publico de las instancias"
  r_entrada       = local.reglas_ENTRADA_fw_publico
  r_salida        = local.reglas_SALIDA_fw_publico
}
# --------------------- INSTANCIAS EC2 PUBLICAS ---------------------
# module "vm_bastion" {
#   source          = "../modulos/ec2-sin-provisioner"
#   count           = 1
#   NUMERO          = count.index
#   NOMBRE_PROYECTO = var.NOMBRE_PROYECTO

#   LISTA_NOMBRE_SERVIDORES = ["bastion"]
#   TIPO_INSTANCIA          = "t2.micro"
#   TIPO_RED                = "public"
#   ID_SUBRED               = module.subred_publica.id_de_la_subred
#   IP_SERVIDOR             = "10.0.150.200"

#   IMAGEN_OS         = data.aws_ami.os_ubuntu.id
#   IDS_SEC_GROUPS    = [module.firewall_ec2_publico.id_de_sg]
#   LLAVE_SSH_PUBLICA = aws_key_pair.llave-ssh-neo.key_name
# }

module "vms_kubernetes" {
  source          = "../modulos/ec2-kmaster"
  count           = 1
  NUMERO          = count.index
  NOMBRE_PROYECTO = var.NOMBRE_PROYECTO

  LISTA_NOMBRE_SERVIDORES = ["kmaster"]
  TIPO_INSTANCIA          = "t2.medium"
  TIPO_RED                = "public"
  ID_SUBRED               = module.subred_publica.id_de_la_subred
  IP_SERVIDOR             = "10.0.150.90"

  IMAGEN_OS         = data.aws_ami.os_ubuntu.id
  IDS_SEC_GROUPS    = [module.firewall_ec2_publico.id_de_sg]
  LLAVE_SSH_PUBLICA = aws_key_pair.llave-ssh-neo.key_name
}

module "vms_kworkers" {
  source          = "../modulos/ec2-kworkers"
  count           = 1
  NUMERO          = count.index
  NOMBRE_PROYECTO = var.NOMBRE_PROYECTO

  LISTA_NOMBRE_SERVIDORES = ["kworker1", "kworker2"]
  TIPO_INSTANCIA          = "t2.medium"
  TIPO_RED                = "public"
  ID_SUBRED               = module.subred_publica.id_de_la_subred
  IP_SERVIDOR             = "10.0.150.9${count.index + 1}"

  IMAGEN_OS         = data.aws_ami.os_ubuntu.id
  IDS_SEC_GROUPS    = [module.firewall_ec2_publico.id_de_sg]
  LLAVE_SSH_PUBLICA = aws_key_pair.llave-ssh-neo.key_name

  depends_on = [
    module.vms_kubernetes
  ]
}

# --------------------- INSTANCIAS EC2 PRIVADAS ---------------------
# module "vms_jenkins" {
#   source          = "../modulos/ec2-sin-provisioner"
#   count           = 3
#   NUMERO          = count.index
#   NOMBRE_PROYECTO = var.NOMBRE_PROYECTO

#   LISTA_NOMBRE_SERVIDORES = ["jmaster", "jagent1", "jagent2"]
#   TIPO_INSTANCIA          = "t2.micro"
#   TIPO_RED                = "privada"
#   ID_SUBRED               = module.subred_privada.id_de_la_subred
#   IP_SERVIDOR             = "10.0.0.1${count.index}"

#   IMAGEN_OS         = data.aws_ami.os_ubuntu.id
#   IDS_SEC_GROUPS    = [module.firewall_ec2_publico.id_de_sg]
#   LLAVE_SSH_PUBLICA = aws_key_pair.llave-ssh-neo.key_name
# }