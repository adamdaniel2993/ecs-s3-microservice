resource "random_password" "nova-db-password" {
  length  = 15
  special = false
}

resource "aws_ssm_parameter" "nova-db-password-ssm" {
  name  = "nova_db_pass"
  type  = "SecureString"
  value = random_password.nova-db-password.result
}

resource "aws_db_instance" "nova_mysql" {
  allocated_storage      = 20
  db_name                = "nova"
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "novaadmin"
  password               = aws_ssm_parameter.nova-db-password-ssm.value
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.nova_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.nova-db-subnet-group.name
}

resource "aws_db_subnet_group" "nova-db-subnet-group" {
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
}