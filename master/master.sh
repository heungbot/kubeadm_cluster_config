#!/bin/bash

# NotReady 상태임을 볼 수 있음. CNI가 설정되지 않아 통신 불가능하기 때문.
kubectl get nodes -o wide

# weave CNI 사용. Flannel or Calico 등으로 대체 가능
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# Ready 상태 확인
kubectl get nodes

# control-plaine 컴포넌트 구성
kubeadm init --pod-network-cidr=[CIDR] --cri-socket unix:///var/run/cri-dockerd.sock

# CIDR = 사용 중인 Network 대역과 겹치지 않게 주의.
# 나의 경우 20.0.0.0/16 대역의 VPC 내부 EC2로 진행하여 위 명령어의 CIDR = 192.168.0.0/16 으로 설정함


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