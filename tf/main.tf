terraform {
  required_providers {
    infisical = {
      source = "infisical/infisical"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "infisical" {
  host          = "https://infisical.n1al.com"
  client_id     = "${var.MACHINE_IDENTITY_CLIENT_ID}"
  client_secret = "${var.MACHINE_IDENTITY_CLIENT_SECRET}"
}

data "infisical_secrets" "my-secrets" {
  env_slug    = "jenkins"
  folder_path = "/"
  workspace_id = "5b2baef4-aa36-49b7-9317-97484dee2466"
}

# Define a security group resource for an instance
resource "aws_security_group" "instance-security-group" {
  # Name the security group using a variable
  name = "${var.my_name}-instance-security-group"

  # Allow inbound SSH traffic from any IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTP traffic from any IP address
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS traffic from any IP address
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tag the security group
  tags = {
    Name     = "${var.my_name}-sg"
    Cost_tag = "ap"
  }
}

# Define an EC2 instance resource
resource "aws_instance" "runner" {
  ami                    = "ami-0a640b520696dc6a8"                         # Amazon machine image id
  instance_type          = "t2.medium"                                     #  the instance type
  user_data              = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install ca-certificates curl wget gnupg nginx -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo usermod -aG docker ubuntu
    sudo usermod -aG docker root

    export AUTH0_SECRET=${var.AUTH0_SECRET}
    export AUTH0_CLIENT_ID=${var.AUTH0_CLIENT_ID}
    export AUTH0_CLIENT_SECRET=${var.AUTH0_CLIENT_SECRET}
    export AUTH0_ISSUER_BASE_URL=${var.AUTH0_ISSUER_BASE_URL}
    export MONGO_URI=${var.MONGO_URI}
    export AUTH0_BASE_URL=${var.AUTH0_BASE_URL}
    git clone https://github.com/nmcc1212/final-tsi-project.git
    cd final-tsi-project/tf
    docker compose up
  EOF
  # Load user data script
  key_name = "bae-tsi-apprentice-plus"
  vpc_security_group_ids = [aws_security_group.instance-security-group.id] # Attach the security group
  root_block_device {
    volume_size = 30 # Specify the root volume size
  }
  provisioner "file" {
    source      = "./remote-exec.sh"
    destination = "/tmp/setup_script.sh"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file(var.pem_path)
      host     = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sh /tmp/setup_script.sh",
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = file(var.pem_path)
    }
  }

  # Tag the instance
  tags = {
    Name     = "${var.my_name}-runner"
    Cost_tag = "ap"
  }
}

# Allocate an Elastic IP address for the instance
resource "aws_eip" "instance_eip" {
  instance = aws_instance.runner.id # Associate the EIP with the instance
  domain   = "vpc"

  # Tag the Elastic IP
  tags = {
    Name     = "${var.my_name}-eip"
    Cost_tag = "ap"
  }
}

# Associate the Elastic IP address with the instance (give it a static ip address)
resource "aws_eip_association" "instance_eip" {
  instance_id   = aws_instance.runner.id # Specify the instance ID
  allocation_id = aws_eip.instance_eip.id     # Specify the allocation ID of the EIP
}

# Fetch the Route 53 zone information
data "aws_route53_zone" "domain" {
  name         = var.domain # Specify the domain name
  private_zone = false      # Indicate it's a public zone
}

# Create a DNS record in the Route 53 zone
resource "aws_route53_record" "dns_record_main" {
  zone_id = data.aws_route53_zone.domain.zone_id # Specify the zone ID (the domain name basically)
  name    = "${var.my_name}"  # Specify the subdomain name
  type    = "A"                                  # Record type is A (so its pointing to an ipv4 address)
  ttl     = "60"                                 # Time to live is 60 seconds (how long it takes to update the information in global dns systems)
  records = [aws_eip.instance_eip.public_ip]     # Use the public IP of the EIP
}