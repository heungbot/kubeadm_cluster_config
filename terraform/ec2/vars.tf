variable "PUBLIC_KEY_PATH" {}

variable "VPC_ID" {}
variable "AZ" {}

variable "PUBLIC_SUBNET_IDS" {}

# Master node
variable "MASTER_AMI" {}
variable "MASTER_TYPE" {}
variable "MASTER_SCRIPT_FILE_PATH" {}

# worker node
variable "WORKER_AMI" {}
variable "WORKER_TYPE" {}
variable "WORKER_SCRIPT_FILE_PATH" {}

