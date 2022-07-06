data "template_file" "mi_bootstrap" {
  template = <<-EOT
                  #!/bin/bash
                  sudo hostnamectl set-hostname ${var.LISTA_NOMBRE_SERVIDORES[var.NUMERO]}
              EOT
}

resource "aws_instance" "mi_vm" {
  tags                   = { Name = "vm-${var.TIPO_RED}-${var.NOMBRE_PROYECTO}-${var.LISTA_NOMBRE_SERVIDORES[var.NUMERO]}-${var.NUMERO+1}" }
  ami                    = var.IMAGEN_OS
  instance_type          = var.TIPO_INSTANCIA
  subnet_id              = var.ID_SUBRED
  vpc_security_group_ids = var.IDS_SEC_GROUPS
  key_name               = var.LLAVE_SSH_PUBLICA
  private_ip             = var.IP_SERVIDOR
  user_data              = data.template_file.mi_bootstrap.rendered
}

output la_ip_publica { value = aws_instance.mi_vm.public_ip }
output la_ip_privada { value = aws_instance.mi_vm.private_ip }