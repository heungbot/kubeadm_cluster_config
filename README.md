# kubeadm_cluster_config

## 01. 구성

#### Public EC2 Instance 3대.
* CPU >= 2, RAM >= 4G, EBS >= 15G
* 비용 최소화를 위해 NAT Gateway 두지 않고, Public Subnet에 위치시킴
  
-> 비용 발생함. 실습 후 빠르게 ```Terraform destroy```

#### 실행 순서
1. common/setup.sh
2. master/master.sh
3. worker/worker.sh
