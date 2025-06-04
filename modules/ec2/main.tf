# Data source for Amazon Linux 2 AMI
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get List of Availability Zones in a Specific Region
# Datasource-1
data "aws_availability_zones" "my_azones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Check if that respective Instance Type is supported in that Specific Region in list of availability Zones
# Get the List of Availability Zones in a Particular region where that respective Instance Type is supported
# Datasource-2
data "aws_ec2_instance_type_offerings" "my_ins_type" {
  for_each = toset(data.aws_availability_zones.my_azones.names)
  
  filter {
    name   = "instance-type"
    values = ["t3.micro"]
  }
  
  filter {
    name   = "location"
    values = [each.key]
  }
  
  location_type = "availability-zone"
}

# Output-1
# Basic Output: All Availability Zones mapped to Supported Instance Types
output "output_v3_1" {
  value = {
    for az, details in data.aws_ec2_instance_type_offerings.my_ins_type : az => details.instance_types
  }
}

# Output-2
# Filtered Output: Exclude Unsupported Availability Zones
output "output_v3_2" {
  value = {
    for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
    az => details.instance_types if length(details.instance_types) != 0
  }
}

# Output-3
# Filtered Output: with Keys Function - Which gets keys from a Map
# This will return the list of availability zones supported for a instance type
output "output_v3_3" {
  value = keys({
    for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
    az => details.instance_types if length(details.instance_types) != 0
  })
}

# Output-4 (additional learning)
# Filtered Output: As the output is list now, get the first item from list (just for learning)
output "output_v3_4" {
  value = keys({
    for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
    az => details.instance_types if length(details.instance_types) != 0
  })[0]
}

# EC2 Instance Creations
resource "aws_instance" "myec2vm" {
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  user_data              = file("${path.module}/install-web.sh")
  key_name               = var.instance_keypair
  vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
  
  # Create EC2 Instance in all Availability Zones of a VPC
  # for_each = toset(data.aws_availability_zones.my_azones.names)
  for_each = toset(keys({
    for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
    az => details.instance_types if length(details.instance_types) != 0
  }))
  
  # You can also use each.value because for list items each.key == each.value
  availability_zone = each.key
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-ec2-${each.key}"
    }
  )
}

# Local-exec provisioner to output EC2 instance details to a file
resource "null_resource" "ec2_output_to_file" {
  # Ensure this runs after all EC2 instances are created
  depends_on = [
    aws_instance.myec2vm
  ]
  
  # This will run the command locally after the EC2 instances are created
  provisioner "local-exec" {
    command = <<-EOT
      cat > ec2_instances_info.txt << EOF
EC2 Instances Information:
-------------------------
${join("\n\n", [for az, instance in aws_instance.myec2vm : <<-INSTANCE
Instance ID: ${instance.id}
Availability Zone: ${instance.availability_zone}
Instance Type: ${instance.instance_type}
AMI: ${instance.ami}
Public IP: ${instance.public_ip}
Private IP: ${instance.private_ip}
Key Pair: ${instance.key_name}
INSTANCE
])}

Instance Type Availability by AZ:
--------------------------------
${join("\n", [for az, details in data.aws_ec2_instance_type_offerings.my_ins_type :
  length(details.instance_types) != 0 ? 
  "AZ: ${az} - Instance Types: ${join(", ", details.instance_types)}" : 
  "AZ: ${az} - No supported instance types"
])}

Security Groups:
--------------
SSH Security Group: ${aws_security_group.vpc-ssh.id}
Web Security Group: ${aws_security_group.vpc-web.id}

Created by Terraform on: $(date)
EOF
    EOT
  }
  
  # This will run when terraform destroy is executed
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'EC2 Instances destroyed on: $(date)' > ec2_destruction_log.txt"
  }
}




# # EC2 Instance Creations
# resource "aws_instance" "myec2vm" {
#   ami                    = data.aws_ami.amzlinux2.id
#   instance_type          = var.instance_type
#   user_data              = file("${path.module}/app1-install.sh")
#   key_name               = var.instance_keypair
#   vpc_security_group_ids = [aws_security_group.vpc-ssh.id, aws_security_group.vpc-web.id]
 
#   # Create EC2 Instance in all Availability Zones of a VPC  
#   # for_each = toset(data.aws_availability_zones.my_azones.names)
#   for_each = toset(keys({for az, details in data.aws_ec2_instance_type_offerings.my_ins_type:
#     az => details.instance_types if length(details.instance_types) != 0 }))
 
#   availability_zone = each.key # You can also use each.value because for list items each.key == each.value
 
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${local.name}-ec2-${each.key}"
#     }
#   )
# }

# # Local-exec provisioner to output EC2 instance details to a file
# resource "null_resource" "ec2_output_to_file" {
#   # Ensure this runs after all EC2 instances are created
#   depends_on = [
#     aws_instance.myec2vm
#   ]

#   # This will run the command locally after the EC2 instances are created
#   provisioner "local-exec" {
#     command = <<-EOT
#       cat > ec2_instances_info.txt << EOF
# EC2 Instances Information:
# -------------------------
# ${join("\n\n", [for az, instance in aws_instance.myec2vm : <<-INSTANCE
# Instance ID: ${instance.id}
# Availability Zone: ${instance.availability_zone}
# Instance Type: ${instance.instance_type}
# AMI: ${instance.ami}
# Public IP: ${instance.public_ip}
# Private IP: ${instance.private_ip}
# Key Pair: ${instance.key_name}
# INSTANCE
# ])}

# Instance Type Availability by AZ:
# --------------------------------
# ${join("\n", [for az, details in data.aws_ec2_instance_type_offerings.my_ins_type : 
#   length(details.instance_types) != 0 ? "AZ: ${az} - Instance Types: ${join(", ", details.instance_types)}" : "AZ: ${az} - No supported instance types"
# ])}

# Security Groups:
# --------------
# SSH Security Group: ${aws_security_group.vpc-ssh.id}
# Web Security Group: ${aws_security_group.vpc-web.id}

# Created by Terraform on: $(date)
# EOF
#     EOT
#   }

#   # This will run when terraform destroy is executed
#   provisioner "local-exec" {
#     when    = destroy
#     command = "echo 'EC2 Instances destroyed on: $(date)' > ec2_destruction_log.txt"
#   }
# }