 resource "aws_instance" "web-1" {
     ami = var.imagename
     availability_zone = "ap-south-1a"
     instance_type = "t2.micro"
     key_name = "feb"
     subnet_id = "${aws_subnet.my-pub-1.id}"
     vpc_security_group_ids = ["${aws_security_group.my-sg.id}"]
     associate_public_ip_address = true	
     tags = {
         Name = "Server-1"
         Env = "Prod"
         Owner = "Sree"
 	CostCenter = "ABCD"
     }
 }
