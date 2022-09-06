#--------------------------------------------------------
#   VPC
#--------------------------------------------------------

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Name = "${var.project}-VPC"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Gateway
#--------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
    project = var.project 
  }
}


#--------------------------------------------------------
#   Public Subnet 1
#--------------------------------------------------------

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr,3,0)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-public1"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Public Subnet 2
#--------------------------------------------------------

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr,3,1)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-public2"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Public Subnet 3
#--------------------------------------------------------

resource "aws_subnet" "public3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr,3,2)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-public3"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Private Subnet 1
#--------------------------------------------------------

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr,3,3)
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-private1"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Private Subnet 2
#--------------------------------------------------------

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr,3,4)
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-private2"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Private Subnet 3
#--------------------------------------------------------

resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr,3,5)
  availability_zone = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-private3"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Public Route Table
#--------------------------------------------------------

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-public-rt"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Public Route
#--------------------------------------------------------

resource "aws_route" "route" {
  route_table_id            = aws_route_table.public-rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id 
  depends_on                = [aws_route_table.public-rt]

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------
#   Public Route table association
#--------------------------------------------------------

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public-rt.id
}

#--------------------------------------------------------
#   EIP
#--------------------------------------------------------

resource "aws_eip" "eip" {
  vpc      = true
}

#--------------------------------------------------------
#   Nat gateway
#--------------------------------------------------------

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-public-nat"
    project = var.project 
  }
  depends_on = [aws_internet_gateway.igw]
}


#--------------------------------------------------------
#   Private Route Table
#--------------------------------------------------------

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-private-rt"
    project = var.project 
  }
}

#--------------------------------------------------------
#   Private Route
#--------------------------------------------------------

resource "aws_route" "route-pvt" {
  route_table_id            = aws_route_table.private-rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat.id
  depends_on                = [aws_route_table.private-rt]

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------
#   Private Route table association
#--------------------------------------------------------

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private-rt.id
}