variable "INSTALA_DOCKER" {
  type = list(any)
  default = [
    "sudo apt remove docker docker-engine docker.io containerd runc",
    "sudo apt update",
    "sudo apt install -y ca-certificates curl gnupg lsb-release",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
    "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt update -y",
    "sudo apt install -y docker-ce docker-ce-cli containerd.io",
    "sudo usermod -aG docker ansible",
    "sudo systemctl start docker",
    "sudo systemctl enable docker",
  ]
}

variable "INSTALA_CRI_O" {
  type = list(any)
  default = [
    "echo \"[PASO 1] Apagar y deshabilitar la SWAP (memoria en disco)\"",
    "swapoff -a",
    "sudo sed -i '/swap/d' /etc/fstab",


    "echo \"[PASO 2] Agregar configuraciones para KUBERNETES necesarias en el Kernel \"",
    "sudo cp /tmp/kubernetes.conf /etc/sysctl.d/kubernetes.conf",
    "sudo sysctl --system >/dev/null 2>&1",


    "echo \"[PASO 3] Habilitar y cargar modulos necesarios para CRI-O en el Kernel \"",
    "sudo cp /tmp/cri-o.conf /etc/modules-load.d/cri-o.conf",
    "sudo modprobe overlay",
    "sudo modprobe br_netfilter",


    "echo \"[PASO 4] Instalar CRI-O \"",
    "OS=xUbuntu_20.04",
    "VERSION=1.24.1",
    "echo \"deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /\" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list",
    "echo \"deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /\" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list",
    "curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key add -",
    "curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -",
    "apt-get update",
    "apt-get install cri-o cri-o-runc",


    "echo \"[PASO 5] Copiar archivo que pide Kubernetes llamado 02-cgroup-manager.conf\"",
    "sudo cp /tmp/02-cgroup-manager.conf /etc/crio/crio.conf.d/02-cgroup-manager.conf",

  
    "echo \"[PASO 6] Reiniciar y habilitar servicio CRI-O \"",
    "sudo systemctl restart crio",
    "sudo systemctl enable crio >/dev/null 2>&1",


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