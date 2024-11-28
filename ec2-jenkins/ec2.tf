# AWS 리전
provider "aws" {
  region = "ap-northeast-2"
}

# VPC
variable "vpc_id" {
  default = "vpc-0c5788b2bddfd326f"
}

# 보안 그룹
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "sg" {
  name        = "saju-api-sg-dev"
  description = "saju api sg dev"
  vpc_id      = var.vpc_id

  # 인바운드 규칙
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "APP"
    from_port   = 3000
    to_port     = 3000
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
    Name    = "saju-api-sg-dev"
    Service = "saju-dev"
  }
}

# EC2
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "ec2" {
  ami                    = "ami-04cb1684c278156a3"    # AMI ID
  instance_type          = "t2.micro"                 # 인스턴스 유형
  key_name               = "saju-key-dev"             # 키 페어
  vpc_security_group_ids = [aws_security_group.sg.id] # 보안그룹 ID
  availability_zone      = "ap-northeast-2a"          # 가용영역
  user_data              = file("./userdata.sh")      # 사용자 데이타
  # 스토리지 정보
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  # 태그 설정
  tags = {
    Name    = "saju-api-dev"
    Service = "saju-dev"
  }
}

# 탄력적 IP 할당
# 위치 : EC2 > 네트워크 및 보안 > 탄력적 IP
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "eip" {
  instance = aws_instance.ec2.id

  tags = {
    Name    = "saju-api-dev"
    Service = "saju-dev"
  }
}

# 탄력적 IP
output "eip_ip" {
  value = aws_eip.eip.public_ip
}
