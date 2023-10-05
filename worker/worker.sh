#!/bin/bash

# setup.sh 파일의 모든 명령어가 성공적으로 실행 되었다면, cluster join만 해주면 오케이

# root 권한으로 worker node join을 위한 명령어. 별도 저장해둠.
kubeadm join 20.0.1.18:6443 --token t9soeo.1pmgctnhniy7ttgu \
--discovery-token-ca-cert-hash sha256:3e2cc935a91d2bbdc486c6c29370103acc679f0a983ffe55ca73401ee74194b0 \
--cri-socket unix:///var/run/cri-dockerd.sock # 이 부붕을 추가해줘야 함.