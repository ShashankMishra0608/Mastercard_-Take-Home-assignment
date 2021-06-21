resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 enable_dns_hostnames = var.enable_dns_hostnames
 enable_dns_support   = var.enable_dns_support

  tags = {
    Terraform = "true"
    Name      = "${var.name}_vpc"
  }
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}_public_subnets"
  }
}

#################
# Private subnet A
#################
resource "aws_subnet" "private_A" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_A[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name}_private_subnets_A"
  }
}

#################
# Private subnet B
#################
resource "aws_subnet" "private_B" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_B[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.name}_private_subnets_B"
  }
}



# creating  NAT Gateway  EIP


resource "aws_eip" "nat" {
  count = length(data.aws_availability_zones.available.names)
  vpc   = true

  tags = {
    Name = "${var.name}_EIP_nat"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(data.aws_availability_zones.available.names)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}_EIP_nat_gateway"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route" "private_A_nat_gateway" {
  count                  = length(data.aws_availability_zones.available.names)
  route_table_id         = aws_route_table.private_A[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_B_nat_gateway" {
  count                  = length(data.aws_availability_zones.available.names)
  route_table_id         = aws_route_table.private_B[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id

  timeouts {
    create = "5m"
  }
}

# Route table association 

resource "aws_route_table_association" "private_A" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.private_A[count.index].id
  route_table_id = aws_route_table.private_A[count.index].id
}

resource "aws_route_table_association" "private_B" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.private_B[count.index].id
  route_table_id = aws_route_table.private_B[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}