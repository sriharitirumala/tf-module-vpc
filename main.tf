resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.tags,
    { Name = "${var.env}-vpc" }
  )
}



## Public Subnets
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main.id

  for_each = var.public_subnets
  tags   = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
    cidr_block = each.value["cidr_block"]
    availability_zone = each.value["availability_zone"]

}

## Internet gateway (IGW)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags   = merge(
    var.tags,
    { Name = "${var.env}-igw" }
  )
}

## NAT Gateway (NATGW)
resource "aws_eip" "nat" {
  for_each      = var.public_subnets
  vpc           = true
}

resource "aws_nat_gateway" "nat-gateway" {
  for_each      = var.public_subnets
  allocation_id = aws_eip[each.value["name"]].id
  subnet_id     = aws_subnet[each.value["name"]].id
  tags   = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}


## Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  for_each     = var.public_subnets
  tags   = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}


## Public Route Table Association
resource "aws_route_table_association" "public-association" {

  for_each       = var.public_subnets
  subnet_id      = lookup(lookup (aws_subnet.public_subnets, each.value["name"], null), "id", null)
  #subnet_id     = aws_subnet.public_subnets[each.value["name"]].id
  route_table_id = aws_route_table.public-route-table[each.value["name"]].id
}


## Private Subnets
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.main.id

  for_each = var.private_subnets
  tags   = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

}


## Private Route Table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id

  for_each     = var.private_subnets
  tags   = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

## Private Route Table Association
resource "aws_route_table_association" "private-association" {

  for_each       = var.private_subnets
  subnet_id      = lookup(lookup (aws_subnet.private_subnets, each.value["name"], null), "id", null)
  #subnet_id     = aws_subnet.private_subnets[each.value["name"]].id
  route_table_id = aws_route_table.private-route-table[each.value["name"]].id
}

