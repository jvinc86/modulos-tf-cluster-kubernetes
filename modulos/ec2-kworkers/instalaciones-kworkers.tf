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

variable "INSTALA_CONTAINERD" {
  type = list(any)
  default = [
    "swapoff -a",
    "sudo sed -i '/swap/d' /etc/fstab",

    "sudo cp /tmp/kubernetes.conf /etc/sysctl.d/kubernetes.conf",
    "sudo sysctl --system",

    "sudo cp /tmp/containerd.conf /etc/modules-load.d/containerd.conf",
    "sudo modprobe overlay",
    "sudo modprobe br_netfilter",

    "sudo apt update -qq",
    "sudo apt install -qq -y containerd apt-transport-https",
    "sudo mkdir -p /etc/containerd",
    "containerd config default | sudo tee /etc/containerd/config.toml",
    "sudo sed -i 's|SystemdCgroup = false|SystemdCgroup = true|g' /etc/containerd/config.toml",
    "sudo systemctl restart containerd",
    "sudo systemctl enable containerd",
  ]
}

variable "INSTALA_KUBE_COMPONENTES" {
  type = list(any)
  default = [
    "sudo apt update -qq",

    "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
    "sudo apt-add-repository -y -s \"deb http://apt.kubernetes.io/ kubernetes-xenial main\"",

    "sudo apt install -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00",
    "sudo apt-mark hold kubelet kubeadm kubectl",
  ]
}

variable "UNIR_NODO_AL_CLUSTER_K8S" {
  type = list(any)
  default = [
    "sudo apt install -y sshpass",

    "sshpass -p '123' scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ansible@kmaster:incluir_nodo_a_cluster.sh ~/incluir_nodo_a_cluster.sh",
    "echo \"sudo $(cat incluir_nodo_a_cluster.sh)\" > ~/comando.sh",
    
    "bash ~/comando.sh"
  ]
}