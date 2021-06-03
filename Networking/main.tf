resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "kelly_vpc"
    }
  
}
#create my application segment
resource "aws_subnet" "my_app_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true 
    availability_zone = "us-east-2a"
    depends_on = [
      aws_vpc.my_vpc
    ]
  tags = {
    "Name" = "APP_Subnet"
  }
}

resource "aws_subnet" "my_db_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = false  
    availability_zone = "us-east-2b"
    depends_on = [
      aws_vpc.my_vpc
    ]
  tags = {
    "Name" = "DB_Subnet"
  }
}
#define routing table
resource "aws_route_table" "my_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      "Name" = "My_Route_table"
    }
  
}
#Associate subnet with routing table
resource "aws_route_table_association" "APP_Route_Association" {
    subnet_id = aws_subnet.my_app_subnet.id 
    route_table_id = aws_route_table.my_route_table.id
}
# create internet gateway for servers to be connected to the internet
resource "aws_internet_gateway" "my_IG" {
    vpc_id = aws_vpc.my_vpc.id
    depends_on = [
      aws_vpc.my_vpc
    ]
    
  
}
#add default route in routing table to point to igw
resource "aws_route" "default_route" {
    route_table_id = aws_route_table.my_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_IG.id
  
}

resource "aws_security_group" "APP_SG" {
    name = "DB_SG"
    description = "Allow web inbound traffic" 
    vpc_id = aws_vpc.my_vpc.id
    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

}
#create a security group for the DB Server (por for mysql 3306)
resource "aws_security_group" "DB_SG" {
    name = "DB_SG"
     vpc_id = aws_vpc.my_vpc.id
    description = "Allow web inbound traffic"
    ingress {
        protocol = "tcp"
        from_port = 3306
        to_port = 3306
        security_groups = [aws_security_group.APP_SG.id]
        
    }
    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
       security_groups = [aws_security_group.APP_SG.id]
    }
   egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#create a private key which can be used to login to webserver
resource "tls_private_key" "web_key" {
    algorithm = "RSA"
  
}
#save public key attributes from the generated key
resource "aws_key_pair" "App-instance-key" {
    key_name = "web-key"
    public_key = tls_private_key.web_key.public_key_openssh
  
}
#save the key to your local system
resource "local_file" "web-key" {
    content = tls_private_key.web_key.private_key_pem
    filename = "web-key.pem"
  
}
#create your webserver instace
resource "aws_instance" "web" {
    ami = "ami-077e31c4939f6a2f3"
    instance_type = "t2.micro"
    count = 1
    subnet_id = aws_subnet.my_app_subnet.id
    key_name = "web-key"
    security_groups = [aws_security_group.APP_SG.id]
    tags = {
      "Name" = "WEBServer1"
    }
  
}


resource "aws_instance" "DB" {
    ami = "ami-077e31c4939f6a2f3"
    instance_type = "t3.micro"
    count = 1
    subnet_id = aws_subnet.my_db_subnet.id
    key_name = "web-key"
    security_groups = [aws_security_group.DB_SG.id]
    tags = {
      "Name" = "DBServer1"
    }
  
}
    
/*
# tranfering the key which will be used to login the DB server to the web server
resource "null_resource" "copy_key_EC2" {
    depends_on = [
      aws_instance.web
    ]
    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -i web-key.pem web-key.pem kelly@${aws_instance.web[0].public_ip}:/home/kelly"
    
    }
}
#testing the webserver to make sure its working fine
resource "null_resource" "running_the_website" {
    depends_on = [
      aws_instance.DB,aws_instance.web
    ]
    provisioner "local-exec" {
        command = "start chrome ${aws_instance.web[0].public_ip}"
    
    }
  
} */
