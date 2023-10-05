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

ufw status # inactive 임을 확인
swapoff -a # k8s memory check를 위해 off

# 표준시간대 변경
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
date

# hostname 변경
hostnamectl hostname k8s-master

# master : 10.0.10.10/20
# worker-1 : 10.0.16.100/20
# worker-2 : 10.0.16.101/20

cat <<EOF | sudo tee /etc/hosts
10.0.10.10 k8s-control-plane
10.0.16.100 worker-1
10.0.16.101 worker-2
EOF


# br_netfilter 모듈을 로드
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# module download?
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
# echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
#   https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list # error 발생 PUBLIC_KEY

echo deb http://apt.kubernetes.io/ kubernetes-xenial main | sudo tee /etc/apt/sources.list.d/kubernetes.list

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
# NotReady 상태임을 볼 수 있음. CNI가 설정되지 않아 통신 불가능하기 때문.

# control-plaine 컴포넌트 구성
# CIDR = 사용 중인 Network 대역과 겹치지 않게 주의.
# 나의 경우 20.0.0.0/16 대역의 VPC 내부 EC2로 진행하여 위 명령어의 CIDR = 192.168.0.0/16 으로 설정함
kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock  >> k8s_init.txt
tail -2 k8s_init.txt > join_command
echo "--cri-socket unix:///var/run/cri-dockerd.sock" >> join_command

# scp command로 join 명령어를 worker node에게 전송.
ssh-keygen && ssh-copy-id root@worker-1 && ssh-copy-id root@worker-2
scp join_command root@wroker-1:/root
scp join_command root@wroker-2:/root

# 명령어 수행 완료되었다면 아래와 같이 Log가 찍힐 것임.
# [addons] Applied essential addon: kube-proxy

# Your Kubernetes control-plane has initialized successfully!

# 이 명령어를 입력한 뒤, Master Node가 속한 Cluster에 Join을 위한 명령어가 로그로 찍힘. 이를 다른 파일에 적절히 포관해두자. 형태는 아래와 같음.

# <join command>
# kubeadm join 10.0.2.50:6443 --token 2whvdj...qbbib \
# 	--discovery-token-ca-cert-hash sha256:7125...78570b57

# Kubectl을 명령 실행 허용하려면 kubeadm init 명령의 실행결과 나온 내용을 동작해야 함
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes -o wide

# Flannel CNI 사용. weave or Calico 등으로 대체 가능
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Ready 상태 확인
kubectl get nodes




