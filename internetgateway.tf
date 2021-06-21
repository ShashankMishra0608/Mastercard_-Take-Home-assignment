###################
# Internet Gateway
###################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}_iGW"
  }

}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-public_routes"
  }

}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes A
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private_A" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}_private_routes_A"
  }
}

#################
# Private routes B
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private_B" {
  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}_private_routes_B"
  }
}
