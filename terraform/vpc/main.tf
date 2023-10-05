# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.PUBLIC_CIDR, count.index)
  availability_zone       = element(var.AZ, count.index)
  count                   = length(var.PUBLIC_CIDR)
  map_public_ip_on_launch = true
}

# public routing table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.PUBLIC_CIDR)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}