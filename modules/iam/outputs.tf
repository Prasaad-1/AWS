output "web_ec2_instance_profile"     { value = aws_iam_instance_profile.web_ec2.name }
output "bastion_instance_profile"     { value = aws_iam_instance_profile.bastion.name }
output "web_ec2_role_arn"             { value = aws_iam_role.web_ec2.arn }
