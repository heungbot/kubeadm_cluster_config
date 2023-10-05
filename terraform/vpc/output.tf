output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "public subnet's id list"
  value       = aws_subnet.public.*.id
}