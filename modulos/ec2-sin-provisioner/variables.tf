# ---------------------------- VARIABLES --------------------------------------
variable "NOMBRE_PROYECTO" {}
variable "TIPO_INSTANCIA" {}
variable "IP_SERVIDOR" {}
variable "IMAGEN_OS" {}
variable "ID_SUBRED" {}
variable "IDS_SEC_GROUPS" {
  type    = list
  default = []
}
variable "LLAVE_SSH_PUBLICA" {}
variable "NUMERO" {}
variable "LISTA_NOMBRE_SERVIDORES" {
  type    = list
  default = []
}
variable "TIPO_RED" {}