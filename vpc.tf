
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags = {
    Name = var.cidr
  }
}

resource "aws_subnet" "public" {
  count = 2
  cidr_block = cidrsubnet(var.cidr, 8, count.index)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public-Subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count = 2
  cidr_block = cidrsubnet(var.cidr, 8, count.index+2)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private-Subnet-${count.index+1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                = aws_vpc.vpc.id
  tags                  = {
    Name                = "igw-vpc-${var.cidr}"
  }
}

resource "aws_route_table" "r-table" {
  vpc_id          = aws_vpc.vpc.id
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = aws_internet_gateway.igw.id
  }
  tags            = {
    Name          = "route-table-public"
  }
}

resource "aws_route_table_association" "r-table-assoc" {
  count           = 2
  subnet_id       = element(aws_subnet.public.*.id, count.index)
  route_table_id  = aws_route_table.r-table.id
}

resource "aws_security_group" "public-ssh" {
  name        = "allow-ssh-public"
  description = "Allow SSH PUBLIC"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public-web" {
  name        = "allow-web-public"
  description = "Allow WEB PUBLIC"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-mysql" {
  name        = "allow-mysql-internal"
  description = "Allow MySQL Internal"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

