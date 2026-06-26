output "vpc_id"            { value = module.networking.vpc_id }
output "alb_dns_name"      { value = module.alb.alb_dns_name }
output "bastion_public_ip" { value = module.bastion.public_ip }
output "web_private_ip"    { value = module.ec2.private_ip }
output "rds_endpoint"      { value = module.rds.db_endpoint }
output "waf_acl_arn"       { value = module.waf.waf_acl_arn }
