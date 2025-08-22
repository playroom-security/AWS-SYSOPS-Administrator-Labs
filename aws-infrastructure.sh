#!/bin/bash


# Variables
REGION="us-east-1"
vpc_cidr="10.10.0.0/16"
public_sub_cidr="10.10.1.0/24"
private_sub_cidr="10.10.2.0/24"


# Create a VPC
vpcId=$(aws ec2 create-vpc \
    --cidr-block $vpc_cidr \
    --region $REGION \
    --t2ag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=aws-sysops-vpc}]' \
    --query 'Vpc.VpcId' \
    --output text)
    

# Create a Private subnet in the VPC
SubnetIdPrivateSubnet=$(aws ec2 create-subnet \
    --region $REGION \
    --vpc-id $vpcId \
    --cidr-block $private_sub_cidr \
    --availability-zone us-east-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=aws-sysops-private-subnet}]' \
    --no-map-public-ip-on-launch \
    --query 'Subnet.SubnetId' \
    --output text)

# Create a Public subnet in the VPC
SubnetIdPublicSubnet=$(aws ec2 create-subnet \
    --vpc-id $vpcId \
    --cidr-block $public_sub_cidr \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=aws-sysops-public-subnet}]' \
    --map-public-ip-on-launch \
    --region $REGION \
    --query 'Subnet.SubnetId' \
    --output text)

# Create an internet gateway
InternetGatewayId=$(aws ec2 create-internet-gateway \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

# Attach the internet gateway to the VPC
aws ec2 attach-internet-gateway \
    --vpc-id $vpcId \
    --internet-gateway-id $InternetGatewayId

# Create a route table for the Public subnet
RouteTableId=$(aws ec2 create-route-table \
    --vpc-id $vpcId \
    --query 'RouteTable.RouteTableId' \
    --output text)

# Create a route to the internet gateway
aws ec2 create-route \
    --route-table-id $RouteTableId \
    --destination-cidr-block "0.0.0.0/0" \
    --gateway-id $InternetGatewayId

# Associate the route table with the subnet
aws ec2 associate-route-table \
    --subnet-id $SubnetIdPublicSubnet \
    --route-table-id $RouteTableId

# Create a security group for the Public subnet
SecurityGroupId=$(aws ec2 create-security-group \
    --region $REGION \
    --group-name "PublicSubnetSG" \
    --description "Security group for Public subnet" \
    --vpc-id $vpcId \
    --query 'GroupId' \
    --output text)

# Authorize inbound SSH traffic to the Public subnet security group
aws ec2 authorize-security-group-ingress \
    --region $REGION \
    --group-id $SecurityGroupId \
    --protocol "tcp" \
    --port "22" \
    --cidr "0.0.0.0/0" 

# Save all the IDs to a file
echo "VPC ID: $vpcId" > aws-infrastructure.txt
echo "Private Subnet ID: $SubnetIdPrivateSubnet" >> aws-infrastructure.txt
echo "Public Subnet ID: $SubnetIdPublicSubnet" >> aws-infrastructure.txt
echo "Internet Gateway ID: $InternetGatewayId" >> aws-infrastructure.txt
echo "Route Table ID: $RouteTableId" >> aws-infrastructure.txt
echo "Security Group ID: $SecurityGroupId" >> aws-infrastructure.txt
echo "Setup complete. Infrastructure details saved to aws-infrastructure.txt"

