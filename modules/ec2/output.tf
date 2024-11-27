output "web_instance_ids" {
  value = aws_instance.web[count.index].id
}