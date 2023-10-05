#!/bin/bash
sudo -i
cat /etc/os-release 

# 2 GB or more of RAM per machine (any less will leave little room for your apps).
# 2 CPUs or more.
lscpu
free -h

# Full network connectivity between all machines in the cluster (public or private network is fine).
# Unique hostname, MAC address, and product_uuid for every node. See here for more details.
hostname

ip addr 


ufw disable && ufw status
swapoff -a

# 표준시간대 변경
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
date

# hostname 변경
hostnamectl hostname k8s-master

vi /etc/hosts # 즉각적인 ip를 script로 수정. 이를 terraform 수준에서 제어?

# 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
# ::1         localhost6 localhost6.localdomain6
# 172.31.13.XX k8s-control-plane
# 172.31.5.XX k8s-worker1
# 172.31.14.XX k8s-worker2
# ...


# br_netfilter 모듈을 로드
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# bridge taffic 보게 커널 파라메터 수정
# 필요한 sysctl 파라미터를 /etc/sysctl.d/conf 파일에 설정하면, 재부팅 후에도 값이 유지된다.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 재부팅하지 않고 sysctl 파라미터 적용하기
sysctl --system

#Update the apt package index and install packages needed to use the Kubernetes apt repository:
apt update
apt install -y apt-transport-https ca-certificates curl

#Download the Google Cloud public signing key:
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://packages.cloud.google.com/apt/doc/apt-key.gpg

#Add the Kubernetes apt repository:
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
  https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
apt update
apt install -y kubelet=1.26.0-00 kubeadm=1.26.0-00 kubectl=1.26.0-00
apt-mark hold kubelet kubeadm kubectl

# -> apt update 명령어에서 에러 발생
# Err:4 https://packages.cloud.google.com/apt kubernetes-xenial InRelease
#   The following signatures couldn't be verified because the public key is not available: NO_PUBKEY B53DC80D13EDEF05
# E: The repository 'http://apt.kubernetes.io kubernetes-xenial InRelease' is not signed.

# Error에서 추출된 Public key 등록
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys [PUBLIC_KEY]
# 이후 update & install 진행

# setup.sh 파일의 모든 명령어가 성공적으로 실행 되었다면, cluster join만 해주면 오케이

# root 권한으로 worker node join을 위한 명령어. 별도 저장해둠.
bash /root/join_command