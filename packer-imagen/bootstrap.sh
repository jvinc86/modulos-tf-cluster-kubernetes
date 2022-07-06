#!/bin/bash
sudo timedatectl set-timezone Europe/Paris

sudo hostnamectl set-hostname template-srv-ubuntu

sudo ufw disable

sudo sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers 

sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

usuario=ansible
contrasena=123

sudo useradd -m -s /bin/bash -G sudo -p $contrasena -U $usuario
echo "$usuario:$contrasena" | sudo chpasswd

sudo mkdir -p /etc/sudoers.d/
sudo touch /etc/sudoers.d/$usuario
echo "$usuario ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$usuario

sudo mkdir -p /home/$usuario/.ssh
sudo touch /home/$usuario/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHznG1lPc3Zb3VV3BBRwOHDUUhE/gIZJthtERuxtvbVH vcamacho@ubuntu-wsl" | sudo tee -a /home/$usuario/.ssh/authorized_keys
sudo chown -R $usuario:$usuario /home/$usuario/
sudo chmod 700 /home/$usuario/.ssh
sudo chmod 600 /home/$usuario/.ssh/authorized_keys

echo "ubuntu:$contrasena" | sudo chpasswd
echo "root:$contrasena" | sudo chpasswd

sudo mkdir -p /root/.ssh
sudo touch /root/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHznG1lPc3Zb3VV3BBRwOHDUUhE/gIZJthtERuxtvbVH vcamacho@ubuntu-wsl" | sudo tee -a /root/.ssh/authorized_keys
sudo chown -R root:root /root/
sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/authorized_keys

sudo sed -i $'s|no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo \'Please login as the user \\\\"ubuntu\\\\" rather than the user \\\\"root\\\\".\';echo;sleep 10;exit 142\" ||g' /root/.ssh/authorized_keys

cat <<ALO | sudo tee -a /etc/hosts
#DNS Locales
10.0.150.200 bastion bt
10.0.150.10 jmaster jenkins
10.0.150.11 jagent1 agent1
10.0.150.12 jagent2 agent2
10.0.150.20 nexus
10.0.150.50 ansible
10.0.150.70 docker
10.0.150.90 kmaster km
10.0.150.91 kworker1 kw1
10.0.150.92 kworker2 kw2
ALO

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y wget curl git