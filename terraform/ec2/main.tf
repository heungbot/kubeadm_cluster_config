resource "aws_key_pair" "tf-main" {
  key_name   = "tf_main_key"
  public_key = file("${var.PUBLIC_KEY_PATH}")
}

resource "aws_instance" "master" {
  ami                    = var.MASTER_AMI
  instance_type          = var.MASTER_TYPE
  subnet_id              = var.PUBLIC_SUBNET_IDS[0]
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  key_name               = "tf_main_key"
  user_data              = file(var.MASTER_SCRIPT_FILE_PATH)

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 20
    volume_type           = "gp2"
  }
}

resource "aws_network_interface" "master-eni" {
  subnet_id = var.PUBLIC_SUBNET_IDS[0]
  private_ips     = ["10.0.10.10"]
  security_groups = [aws_security_group.k8s-sg.id]

  attachment {
    instance     = aws_instance.master.id
    device_index = 1
  }
}

resource "aws_instance" "worker" {
  count                  = 2
  ami                    = var.WORKER_AMI
  instance_type          = var.WORKER_TYPE
  subnet_id              = var.PUBLIC_SUBNET_IDS[1]
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  key_name               = "tf_main_key"
  user_data              = file(var.WORKER_SCRIPT_FILE_PATH)

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 15
    volume_type           = "gp2"
  }
}

resource "aws_network_interface" "worker-eni" {
  count     = 2
  subnet_id = var.PUBLIC_SUBNET_IDS[1]
  private_ips     = ["10.0.16.${count.index + 100}"]
  security_groups = [aws_security_group.k8s-sg.id]

  attachment {
    instance     = element(aws_instance.worker.*.id, count.index)
    device_index = 1
  }
}

resource "aws_security_group" "k8s-sg" {
  name   = "k8s-sg"
  vpc_id = var.VPC_ID

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] # for test
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}