variable "INSTALA_CRI_O" {
  type = list(any)
  default = [
    "echo \"[PASO 1] Apagar y deshabilitar la SWAP (memoria en disco)\"",
    "sudo swapoff -a",
    "sudo sed -i '/swap/d' /etc/fstab",

    "echo \"[PASO 2] Agregar configuraciones para KUBERNETES necesarias en el Kernel \"",
    "sudo cp /tmp/k8s.conf /etc/sysctl.d/k8s.conf",
    "sudo sysctl --system >/dev/null 2>&1",

    "echo \"[PASO 3] Habilitar y cargar modulos necesarios para CRI-O en el Kernel \"",
    "sudo cp /tmp/cri-o.conf /etc/modules-load.d/cri-o.conf",
    "sudo modprobe overlay",
    "sudo modprobe br_netfilter",

    "echo \"[PASO 4] Instalar CRI-O \"",
    "echo \"   [4.1] Seleccionar cual OS Linux (ver pagina: cri-o.io) y cual VERSION de CRI-O\"",
    "OS=xUbuntu_22.04",
    "VERSION_CRI_O=1.24",

    "echo \"   [4.2] Agregar repositorio APT de KUBIC y CRI-O\"",
    "echo \"deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /\" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list >/dev/null 2>&1",
    "echo \"deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION_CRI_O/$OS/ /\" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION_CRI_O.list >/dev/null 2>&1",
    "sudo mkdir -p /usr/share/keyrings",
    "curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg >/dev/null 2>&1",
    "curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION_CRI_O/$OS/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg >/dev/null 2>&1",

    "echo \"   [4.3] Instalar:  cri-o   y  cri-o-runc \"",    
    "sudo apt update >/dev/null 2>&1",
    "sudo apt install -y cri-o cri-o-runc >/dev/null 2>&1",
 
    "echo \"[PASO 5] Reiniciar y habilitar servicio CRI-O \"",
    "sudo systemctl daemon-reload",
    "sudo systemctl start crio.service",
    "sudo systemctl enable crio.service >/dev/null 2>&1",

    "echo \"[PASO 6] Instalar CRI Tools\"",
    "sudo apt install -y cri-tools >/dev/null 2>&1",

    "echo \"[PASO 7] Configurar ALIAS linux, la MERMA de la MERMELADA\"",
    "git clone https://github.com/jvinc86/alias-ubuntu.git >/dev/null 2>&1",
    "cd alias-ubuntu",
    "sed -i 's/mi_shell=zshrc/mi_shell=bashrc/g' alias.sh",
    "bash alias.sh >/dev/null 2>&1",
    "cd .. && rm -rf alias-ubuntu/",
  ]
}

variable "INSTALA_KUBE_COMPONENTES" {
  type = list(any)
  default = [
    "echo \"[PASO 1] Actualizar APT repositorio\"",
    "sudo apt update -qq >/dev/null 2>&1",

    "echo \"[PASO 2] Agregar repositorio APT para KUBERNETES\"",
    "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - > /dev/null 2>&1",
    "sudo apt-add-repository -y -s \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" > /dev/null 2>&1",

    "echo \"[PASO 3] Instalar KUBERNETES Componentes\"",
    "echo \"   [3.1] Instala kubeadm (Herramienta permite crear CLUSTER KUBERNETES. Comandos: kubeadm init, kubeadm join)\"",
    "echo \"   [3.2] Instala kubelet (Agente que se asegura de que los contenedores estén corriendo)\"",
    "echo \"   [3.3] Instala kubectl (CLI - Command-line interface)\"",
    "sudo apt install -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00 >/dev/null 2>&1",

    "echo \"[PASO 4] Prevenir que componentes kubernetes se actualizen o remuevan (apt-mark hold)\"",
    "sudo apt-mark hold kubelet kubeadm kubectl >/dev/null 2>&1",
  ]
}

variable "UNIR_NODO_AL_CLUSTER_K8S" {
  type = list(any)
  default = [
    "echo \"[PASO 1] Actualizar APT repositorio\"",
    "sudo apt update -qq >/dev/null 2>&1",

    "echo \"[PASO 2] Instalar SSHPASS\"",
    "sudo apt install -y sshpass >/dev/null 2>&1",

    "echo \"[PASO 3] Con SSHPASS traer remotamente el archivo con COMANDO JOIN desde el CONTROL PLANE\"",
    "comando=comando_JOIN_para_workers.sh",
    "sshpass -p '123' scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ansible@kmaster:$comando ~/$comando",
    "echo \"sudo $(cat ~/$comando)\" > ~/comando_con_sudo.sh",
    "rm -rf ~/$comando",

    "echo \"[PASO 4] Ejecutar el comando JOIN desde el archivo traido con SSHPASS\"", 
    "bash ~/comando_con_sudo.sh >/dev/null 2>&1",
  ]
}