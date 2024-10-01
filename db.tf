# Run this in second phase once networking deployed in new aws account

resource "aws_db_subnet_group" "climatep-private" {
    subnet_ids = ["subnet-09bc3f9c0455063f0","subnet-0b7020f4790905f99","subnet-0467b90cf4035061d"]
    name = "climatep-private"
  
}

resource "aws_db_instance" "climetpdb" {
    identifier = "climetpdb"
    instance_class = "db.t3.small"
    allocated_storage = 20
    storage_type = "gp3"
    engine = "mysql"
    db_subnet_group_name = "climatep-private"
    vpc_security_group_ids = ["sg-06c77fbb4dc7d3eed"]
    username = "admin"
    password = "climetp2024"
    publicly_accessible = false
}
