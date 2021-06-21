#########   SG   ##########

resource "aws_security_group" "publicSG" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.main.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

  egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

    tags = {
    Name = "${var.name}_allow_from_WEB"
  }

}

resource "aws_security_group" "privateSG" {
   name        = "allow_lb_traffic"
   description = "Allow LB traffic to asg group"
   vpc_id      = aws_vpc.main.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     security_groups = [aws_security_group.publicSG.id]
   }
   
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     security_groups = [aws_security_group.publicSG.id]
   }

   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     security_groups = [aws_security_group.publicSG.id]
  }

  egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
    Name = "${var.name}_allow_from_public_sg"
  }
  depends_on = [aws_security_group.publicSG]
}

