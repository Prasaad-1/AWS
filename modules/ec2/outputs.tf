output "instance_id"         { value = aws_instance.web.id }
output "private_ip"          { value = aws_instance.web.private_ip }
output "availability_zone"   { value = aws_instance.web.availability_zone }
