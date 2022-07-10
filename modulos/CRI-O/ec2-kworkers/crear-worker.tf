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

  connection {
    type        = "ssh"
    user        = "ansible"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.public_ip
  } 

  provisioner "file" {
      source      = "${path.module}/containerd.conf"
      destination = "/tmp/containerd.conf"
  }

  provisioner "file" {
      source      = "${path.module}/kubernetes.conf"
      destination = "/tmp/kubernetes.conf"
  }
  provisioner "remote-exec" { inline = var.INSTALA_CRI_O }
  provisioner "remote-exec" { inline = var.INSTALA_KUBE_COMPONENTES }
  provisioner "remote-exec" { inline = var.UNIR_NODO_AL_CLUSTER_K8S }

}

output la_ip_publica { value = aws_instance.mi_vm.public_ip }
output la_ip_privada { value = aws_instance.mi_vm.private_ip }