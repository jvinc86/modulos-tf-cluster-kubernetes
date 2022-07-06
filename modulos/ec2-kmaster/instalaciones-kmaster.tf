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

variable "INICIA_MASTER_K8S" {
  type = list(any)
  default = [
    "sudo kubeadm config images pull",
    "sudo kubeadm init --apiserver-advertise-address=10.0.150.90 --pod-network-cidr=192.168.0.0/16 | tee ~/inicializacion_master.log",
    "sudo kubeadm token create --print-join-command | tee ~/incluir_nodo_a_cluster.sh",

    "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml | tee ~/deploy_red_calisto.log",

    "mkdir -p ~/.kube",
    "sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config",
    "sudo chown $(id -u):$(id -g) ~/.kube/config",

    "echo \"export KUBECONFIG=/etc/kubernetes/admin.conf\" | sudo tee -a /root/.bashrc",
  ]
}