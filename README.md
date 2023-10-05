# kubeadm_cluster_config

### Public EC2 Instance 3대.
* CPU >= 2, RAM >= 4G, EBS >= 15G
* 비용 발생함. 실습 후 빠르게 ```Terraform destroy```
* 비용 최소화를 위해 NAT Gateway 두지 않고, Public Subnet에 위치시킴


### 구성 다이어 그램
<img width="631" alt="스크린샷 2023-10-06 오전 1 18 21" src="https://github.com/heungbot/kubeadm_cluster_config/assets/97264115/0989f3fb-e37f-4705-8c1f-0d8379bdd7d5">

### 구성 결과
<img width="1003" alt="스크린샷 2023-10-05 오후 5 28 31" src="https://github.com/heungbot/kubeadm_cluster_config/assets/97264115/d2ea4f51-af4d-470c-9520-7784e1429a92">
