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

## Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  for_each     = var.public_subnets
  tags   = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
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
