#!/bin/bash

set -euo pipefail


# Variables
REGION="us-east-1"
vpc_cidr="10.10.0.0/16"
public_sub_cidr="10.10.1.0/24"
private_sub_cidr="10.10.2.0/24"
AMI_ID="ami-08a6efd148b1f7504" # Amazon Linux 2 AMI (HVM), SSD Volume Type for us-east-1
INSTANCE_TYPE="t3.micro"
KEY_NAME="my-key-pair" # Replace with your existing key pair name
RoleName="ec2-cloudwatch-role"
InstanceProfileName="ec2-cloudwatch-profile"
SECURITY_GROUP="PublicSubnetSG" # Replace with your existing security group name   



# Create a VPC
echo "Creating VPC with CIDR block $vpc_cidr"
vpcId=$(aws ec2 create-vpc \
    --cidr-block $vpc_cidr \
    --region $REGION \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=aws-sysops-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text)
echo "VPC ID: $vpcId" > monitoring-setup.txt

# Create an internet gateway
echo "Creating Internet Gateway"
InternetGatewayId=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)
echo "Internet Gateway ID: $InternetGatewayId" >> monitoring-setup.txt
sleep 5

# Attach the internet gateway to the VPC
echo "Attaching Internet Gateway to VPC"
aws ec2 attach-internet-gateway \
    --vpc-id $vpcId \
    --internet-gateway-id $InternetGatewayId \
    > /dev/null
sleep 5    

# Create a Private subnet in the VPC
echo "Creating Private subnet with CIDR block $private_sub_cidr"
SubnetIdPrivateSubnet=$(aws ec2 create-subnet \
    --region $REGION \
    --vpc-id $vpcId \
    --cidr-block $private_sub_cidr \
    --availability-zone us-east-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=aws-sysops-private-subnet}]' \
    --query 'Subnet.SubnetId' \
    --output text)
echo "Private Subnet ID: $SubnetIdPrivateSubnet" >> monitoring-setup.txt
sleep 5

# Create a route table for the Private subnet
echo "Creating Route Table for Public subnet"
PrivateRouteTableId=$(aws ec2 create-route-table \
    --vpc-id $vpcId \
    --query 'RouteTable.RouteTableId' \
    --output text)
echo "Route Table ID: $PrivateRouteTableId" >> monitoring-setup.txt
# Wait for the route table to be created
sleep 5

# Associate the route table with the Private subnet
echo "Associating Route Table with Private subnet"
aws ec2 associate-route-table \
    --route-table-id $PrivateRouteTableId \
    --subnet-id $SubnetIdPrivateSubnet \
    > /dev/null
# Wait for the association to be created
sleep 5

# Create a Public subnet in the VPC
echo "Creating Public subnet with CIDR block $public_sub_cidr"
SubnetIdPublicSubnet=$(aws ec2 create-subnet \
    --vpc-id $vpcId \
    --cidr-block $public_sub_cidr \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=aws-sysops-public-subnet}]' \
    --region $REGION \
    --query 'Subnet.SubnetId' \
    --output text)
echo "Public Subnet ID: $SubnetIdPublicSubnet" >> monitoring-setup.txt
# Wait for the subnets to be created
sleep 5

# Enable auto-assign public IP on the Public subnet
echo "Enabling auto-assign public IP on Public subnet"
aws ec2 modify-subnet-attribute \
    --subnet-id $SubnetIdPublicSubnet \
    --map-public-ip-on-launch \
    > /dev/null
# Wait for the subnet attribute to be modified
sleep 5

# Create a route table for the Public subnet
echo "Creating Route Table for Public subnet"
RouteTableId=$(aws ec2 create-route-table \
    --vpc-id $vpcId \
    --query 'RouteTable.RouteTableId' \
    --output text)
echo "Route Table ID: $RouteTableId" >> monitoring-setup.txt
# Wait for the route table to be created
sleep 5


# Create a route to the internet gateway
echo "Creating route to Internet Gateway in Route Table"
aws ec2 create-route \
    --route-table-id $RouteTableId \
    --destination-cidr-block "0.0.0.0/0" \
    --gateway-id $InternetGatewayId
sleep 5

# Associate the route table with the Public subnet
echo "Associating Route Table with Public subnet"
aws ec2 associate-route-table \
    --subnet-id $SubnetIdPublicSubnet \
    --route-table-id $RouteTableId \
    > /dev/null
# Wait for the association to be created
sleep 5

# Create a security group for the Public subnet
echo "Creating Security Group for Public subnet"
SecurityGroupId=$(aws ec2 create-security-group \
    --region $REGION \
    --group-name $SECURITY_GROUP \
    --description "Security group for Public subnet" \
    --vpc-id $vpcId \
    --query 'GroupId' \
    --output text)
echo "Security Group ID: $SecurityGroupId" >> monitoring-setup.txt
# Wait for the security group to be created
sleep 5


# Authorize inbound SSH traffic to the Public subnet security group
echo "Authorizing inbound SSH traffic to Security Group"
aws ec2 authorize-security-group-ingress \
    --region $REGION \
    --group-id $SecurityGroupId \
    --protocol "tcp" \
    --port "22" \
    --cidr "0.0.0.0/0" \
    > /dev/null
# Wait for the rule to be created
sleep 5



# Create a key pair
echo "Creating key pair for EC2 instance"
aws ec2 delete-key-pair --key-name "my-key-pair" || true # Delete existing key pair if it exists
sleep 5
aws ec2 create-key-pair \
    --key-name "my-key-pair" \
    --key-type "rsa" \
    --key-format "pem" \
    --output text > my-key-pair.pem
chmod 400 my-key-pair.pem
echo "Key pair created and saved to my-key-pair.pem" >> monitoring-setup.txt
# Wait for the key pair to be created
sleep 5

# Launch EC2 instance
echo "Launching EC2 instance in Public subnet"
InstanceId=$(aws ec2 run-instances \
    --region $REGION \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --subnet-id $SubnetIdPublicSubnet \
    --associate-public-ip-address \
    --security-group-ids $SECURITY_GROUP \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=aws-sysops-ec2-instance}]' \
    --key-name $KEY_NAME \
    --output text \
    --query 'Instances[0].InstanceId')
echo "EC2 Instance ID: $InstanceId" >> monitoring-setup.txt
# Wait for the instance to be in running state
sleep 30

# Get the public IP address of the EC2 instance
echo "Retrieving public IP address of the EC2 instance"
public_ip=$(aws ec2 describe-instances \
    --region $REGION \
    --instance-ids $INSTANCE_ID \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)
if [ "$public_ip" == "None" ]; then
    echo "Failed to retrieve public IP address. Exiting."
    exit 1
fi

# Create an IAM role for the EC2 instance
echo "Creating IAM role for EC2 instance"
aws iam create-role \
    --role-name $RoleName \
    --assume-role-policy-document file://assume-role-trust-policy.json \
    --region $REGION \  
    > /dev/null

# Attach the CloudWatch policy to the role
echo "Attaching CloudWatch policy to the IAM role"
aws iam attach-role-policy \
    --role-name $RoleName \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
    --region $REGION \
    > /dev/null
sleep 5

# Create a Instance Profile and attach to the EC2 instance
echo "Creating Instance Profile for EC2 instance"
aws iam create-instance-profile \
    --instance-profile-name $InstanceProfileName \
    --region $REGION \
    > /dev/null
sleep 5

# Attach IAM Role to the Instance Profile
echo "Attaching IAM Role to Instance Profile"
aws iam add-role-to-instance-profile \
    --instance-profile-name $InstanceProfileName \
    --role-name $RoleName \
    --region $REGION \
    > /dev/null
sleep 5


echo "EC2 instance launched in $REGION using AMI $AMI_ID"
echo "Public IP of the instance: $public_ip"


