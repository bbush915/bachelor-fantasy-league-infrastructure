output "vpc_id" {
  value = aws_vpc.bfl_vpc.id
}

output "public_subnet_ids" {
  value = [aws_subnet.bfl_public_subnet_1.id, aws_subnet.bfl_public_subnet_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.bfl_private_subnet_1.id, aws_subnet.bfl_private_subnet_2.id]
}
