module "vpc" {
  source      = "./vpc"
  VPC_CIDR    = "10.0.0.0/16"
  PUBLIC_CIDR = ["10.0.0.0/20", "10.0.16.0/20"]
  AZ          = ["ap-northeast-2a", "ap-northeast-2c"]
}

module "ec2" {
  source            = "./ec2"
  PUBLIC_KEY_PATH   = "/Users/bangdaeseonsaeng/.ssh/id_rsa.pub"
  AZ                = ["ap-northeast-2a", "ap-northeast-2c"]
  VPC_ID            = module.vpc.vpc_id
  PUBLIC_SUBNET_IDS = tolist(module.vpc.public_subnet_ids)

  MASTER_AMI              = "ami-0c9c942bd7bf113a2"
  MASTER_TYPE             = "t2.medium"
  MASTER_SCRIPT_FILE_PATH = "../master/master.sh"

  WORKER_AMI              = "ami-0c9c942bd7bf113a2"
  WORKER_TYPE             = "t2.medium"
  WORKER_SCRIPT_FILE_PATH = "../worker/worker.sh"
}
