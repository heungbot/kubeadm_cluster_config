# kubeadm_cluster_config

## 구성

### Public EC2 Instance 3대.
* CPU >= 2, RAM >= 4G, EBS >= 15G
* 비용 최소화를 위해 NAT Gateway 두지 않고, Public Subnet에 위치시킴
  
-> 비용 발생함. 실습 후 빠르게 ```Terraform destroy```

<img width="1003" alt="스크린샷 2023-10-05 오후 5 28 31" src="https://github.com/heungbot/kubeadm_cluster_config/assets/97264115/32a39944-a1cf-44be-9712-2722273a512f">

