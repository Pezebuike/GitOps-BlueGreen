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




