# kubeadm_cluster_config

## 01. 구성

#### EC2 Instance 3대.
* CPU >= 2, RAM >= 4G, EBS >= 15G
-> 비용 발생함. 실습 후 빠르게 ```Terraform destroy```

#### 실행 순서
1. common/setup.sh
2. master/master.sh
3. worker/worker.sh
