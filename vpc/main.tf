# Create vpc

data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = true
}

#Creating Public Subnet
resource "aws_subnet" "public" {
    count = length(data.aws_availability_zones.available.names)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = cidrsubnet(var.cidr_public_block, var.cidr_public_newbits,count.index)
    vpc_id = aws_vpc.this.id
    map_public_ip_on_launch = true
    tags = {
        Name="${var.name}-public-${data.aws_availability_zones.available.names[count.index]}"
    }
}

#Create Internet Gateway 
resource "aws_internet_gateway" "internet-gw" {
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.name}-internet-gw"
    }
}

#Create Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gw.id
    }
    tags = {
        Name = "public-rt"
    }
    
}

#Route Table Association
resource "aws_route_table_association" "public" {
    count = length(data.aws_availability_zones.available.names)
    subnet_id = aws_subnet.public.*.id[count.index]
    route_table_id = aws_route_table.public.id
}

# Create Private Subnet
resource "aws_subnet" "private" {
    depends_on = [ aws_subnet.public ]
    count = length(data.aws_availability_zones.available.names)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = cidrsubnet(var.cidr_private_block,var.cidr_private_newbits,(count.index+1))
    vpc_id = aws_vpc.this.id
    tags = {
        Name="${var.name}-private-${data.aws_availability_zones.available.names[count.index]}"
    }
}

resource "aws_route_table" "private" {
    count = length(aws_subnet.private)
    vpc_id = aws_vpc.this.id
    
}

# Route Table Association
resource "aws_route_table_association" "private" {
    count = length(aws_subnet.private)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

# Create Nat Gateway
resource "aws_eip" "nat" {
    count = var.nat_ha_gateway ? length(aws_subnet.public) : 0
    vpc = true
}

resource "aws_nat_gateway" "this" {
    count = var.nat_ha_gateway ? length(aws_subnet.public) : 0
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id
    depends_on = [ aws_internet_gateway.internet-gw ]
    
}

resource "aws_route" "nat-gateway" {
    count = var.nat_ha_gateway ? length(aws_subnet.private) : 0
    route_table_id = aws_route_table.private[count.index].id
    nat_gateway_id = aws_nat_gateway.this[count.index].id
    destination_cidr_block = "0.0.0.0/0"
}


# Public Security Group 
resource "aws_security_group" "public-sg" {
    name = "public-sg"
    vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "public-out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = aws_security_group.public-sg.id
}

resource "aws_security_group_rule" "public-ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = aws_security_group.public-sg.id
}

resource "aws_security_group_rule" "public-http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = aws_security_group.public-sg.id
}

resource "aws_security_group_rule" "public-https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = aws_security_group.public-sg.id
}

# Private SG
resource "aws_security_group" "private-sg" {
    name = "private-sg"
    vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "private-out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = aws_security_group.private-sg.id
}

resource "aws_security_group_rule" "private-in" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    cidr_blocks = [ aws_vpc.this.cidr_block ]
    security_group_id = aws_security_group.private-sg.id
}
