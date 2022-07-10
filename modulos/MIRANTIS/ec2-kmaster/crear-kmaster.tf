data "template_file" "mi_bootstrap" {
  template = <<-EOT
                  #!/bin/bash
                  sudo hostnamectl set-hostname ${var.LISTA_NOMBRE_SERVIDORES[var.NUMERO]}
                  sudo sed -i $'s|no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo \'Please login as the user \\\\"ubuntu\\\\" rather than the user \\\\"root\\\\".\';echo;sleep 10;exit 142\" ||g' /root/.ssh/authorized_keys
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
      source      = "${path.module}/cri-o.conf"
      destination = "/tmp/cri-o.conf"
  }

  provisioner "file" {
      source      = "${path.module}/k8s.conf"
      destination = "/tmp/k8s.conf"
  }
#   provisioner "file" {
#       source      = "${path.module}/02-cgroup-manager.conf"
#       destination = "/tmp/02-cgroup-manager.conf"
#   }
  provisioner "remote-exec" { inline = var.INSTALA_CRI_O }
  provisioner "remote-exec" { inline = var.INSTALA_KUBE_COMPONENTES }
  provisioner "remote-exec" { inline = var.INICIA_MASTER_K8S }
}

output la_ip_publica { value = aws_instance.mi_vm.public_ip }
output la_ip_privada { value = aws_instance.mi_vm.private_ip }