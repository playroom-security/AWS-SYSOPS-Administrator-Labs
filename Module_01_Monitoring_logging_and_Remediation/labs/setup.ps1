# PowerShell AWS setup script

# Variables
$REGION = "us-east-1"
$vpc_cidr = "10.10.0.0/16"
$public_sub_cidr = "10.10.1.0/24"
$private_sub_cidr = "10.10.2.0/24"
$AMI_ID = "ami-08a6efd148b1f7504"
$INSTANCE_TYPE = "t3.micro"
$KEY_NAME = "my-key-pair"
$RoleName = "ec2CloudwatchRole"
$InstanceProfileName = "ec2CloudwatchProfile"
$SECURITY_GROUP = "PublicSubnetSG"

# Create a VPC
Write-Host "Creating VPC with CIDR block $vpc_cidr"
$vpcId = (aws ec2 create-vpc `
    --cidr-block $vpc_cidr `
    --region $REGION `
    --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=aws-sysops-vpc}]" `
    --query "Vpc.VpcId" `
    --output text)
"VPC ID: $vpcId" | Out-File -FilePath monitoring-setup.txt

# Create an internet gateway
Write-Host "Creating Internet Gateway"
$InternetGatewayId = (aws ec2 create-internet-gateway `
    --query "InternetGateway.InternetGatewayId" `
    --output text)
"Internet Gateway ID: $InternetGatewayId" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 5

# Attach the internet gateway to the VPC
Write-Host "Attaching Internet Gateway to VPC"
aws ec2 attach-internet-gateway `
    --vpc-id $vpcId `
    --internet-gateway-id $InternetGatewayId | Out-Null
Start-Sleep -Seconds 5

# Create a Private subnet in the VPC
Write-Host "Creating Private subnet with CIDR block $private_sub_cidr"
$SubnetIdPrivateSubnet = (aws ec2 create-subnet `
    --region $REGION `
    --vpc-id $vpcId `
    --cidr-block $private_sub_cidr `
    --availability-zone "us-east-1b" `
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=aws-sysops-private-subnet}]" `
    --query "Subnet.SubnetId" `
    --output text)
"Private Subnet ID: $SubnetIdPrivateSubnet" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 5

# Create a route table for the Private subnet
Write-Host "Creating Route Table for Private subnet"
$PrivateRouteTableId = (aws ec2 create-route-table `
    --vpc-id $vpcId `
    --query "RouteTable.RouteTableId" `
    --output text)
"Route Table ID: $PrivateRouteTableId" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 5

# Associate the route table with the Private subnet
Write-Host "Associating Route Table with Private subnet"
aws ec2 associate-route-table `
    --route-table-id $PrivateRouteTableId `
    --subnet-id $SubnetIdPrivateSubnet | Out-Null
Start-Sleep -Seconds 5

# Create a Public subnet in the VPC
Write-Host "Creating Public subnet with CIDR block $public_sub_cidr"
$SubnetIdPublicSubnet = (aws ec2 create-subnet `
    --vpc-id $vpcId `
    --cidr-block $public_sub_cidr `
    --availability-zone "us-east-1a" `
    --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=aws-sysops-public-subnet}]" `
    --region $REGION `
    --query "Subnet.SubnetId" `
    --output text)
"Public Subnet ID: $SubnetIdPublicSubnet" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 5

# Enable auto-assign public IP on the Public subnet
Write-Host "Enabling auto-assign public IP on Public subnet"
aws ec2 modify-subnet-attribute `
    --subnet-id $SubnetIdPublicSubnet `
    --map-public-ip-on-launch | Out-Null
Start-Sleep -Seconds 5

# Create a route table for the Public subnet
Write-Host "Creating Route Table for Public subnet"
$RouteTableId = (aws ec2 create-route-table `
    --vpc-id $vpcId `
    --query "RouteTable.RouteTableId" `
    --output text)
"Route Table ID: $RouteTableId" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 5

# Create a route to the internet gateway
Write-Host "Creating route to Internet Gateway in Route Table"
aws ec2 create-route `
    --route-table-id $RouteTableId `
    --destination-cidr-block "0.0.0.0/0" `
    --gateway-id $InternetGatewayId | Out-Null
Start-Sleep -Seconds 5

# Associate the route table with the Public subnet
Write-Host "Associating Route Table with Public subnet"
aws ec2 associate-route-table `
    --subnet-id $SubnetIdPublicSubnet `
    --route-table-id $RouteTableId | Out-Null
Start-Sleep -Seconds 5

# Create a security group for the Public subnet
Write-Host "Creating Security Group for Public subnet"
$SecurityGroupId = (aws ec2 create-security-group `
    --region $REGION `
    --group-name $SECURITY_GROUP `
    --description "Security group for Public subnet" `
    --vpc-id $vpcId `
    --query "GroupId" `
    --output text)
"Security Group ID: $SecurityGroupId" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 5

# Authorize inbound SSH traffic to the Public subnet security group
Write-Host "Authorizing inbound SSH traffic to Security Group"
aws ec2 authorize-security-group-ingress `
    --region $REGION `
    --group-id $SecurityGroupId `
    --protocol "tcp" `
    --port "22" `
    --cidr "0.0.0.0/0" | Out-Null
Start-Sleep -Seconds 5

# Create a key pair
Write-Host "Creating key pair for EC2 instance"
aws ec2 delete-key-pair --key-name $KEY_NAME | Out-Null
Start-Sleep -Seconds 5
aws ec2 create-key-pair `
    --key-name $KEY_NAME `
    --key-type "rsa" `
    --key-format "pem" `
    --output text | Out-File -FilePath "my-key-pair.pem"
icacls "my-key-pair.pem" /inheritance:r /grant:r "$($env:USERNAME):R"
"Key pair created and saved to my-key-pair.pem" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 5

# Launch EC2 instance
Write-Host "Launching EC2 instance in Public subnet"
$InstanceId = (aws ec2 run-instances `
    --region $REGION `
    --image-id $AMI_ID `
    --count 1 `
    --instance-type $INSTANCE_TYPE `
    --subnet-id $SubnetIdPublicSubnet `
    --associate-public-ip-address `
    --security-group-ids $SecurityGroupId `
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=aws-sysops-ec2-instance}]" `
    --key-name $KEY_NAME `
    --output text `
    --query "Instances[0].InstanceId")
"EC2 Instance ID: $InstanceId" | Out-File -Append -FilePath monitoring-setup.txt
Start-Sleep -Seconds 10

# Get the public IP address of the EC2 instance
Write-Host "Retrieving public IP address of the EC2 instance"
$public_ip = (aws ec2 describe-instances `
    --region $REGION `
    --instance-ids $InstanceId `
    --filters "Name=instance-state-name,Values=running" `
    --query "Reservations[0].Instances[0].PublicIpAddress" `
    --output text)
if ($public_ip -eq "None") {
    Write-Host "Failed to retrieve public IP address. Exiting."
    exit 1
}

# Create an IAM role for the EC2 instance
@"
{
    `"Version`": `"2012-10-17`",
    `"Statement`": [
        {
            `"Effect`": `"Allow`",
            `"Principal`": {
                `"Service`": `"ec2.amazonaws.com`"
            },
            `"Action`": `"sts:AssumeRole`"
        }
    ]
}
"@ | Set-Content -Path "assume-role-trust-policy.json"

Write-Host "Creating IAM role for EC2 instance"
aws iam create-role --role-name $RoleName `
    --assume-role-policy-document file://assume-role-trust-policy.json | Out-Null

# Attach the CloudWatch policy to the role
Write-Host "Attaching CloudWatch policy to the IAM role"
aws iam attach-role-policy `
    --role-name $RoleName `
    --policy-arn "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" | Out-Null
Start-Sleep -Seconds 5

# Create a Instance Profile and attach to the EC2 instance
Write-Host "Creating Instance Profile for EC2 instance"
aws iam create-instance-profile `
    --instance-profile-name $InstanceProfileName | Out-Null
Start-Sleep -Seconds 5

# Attach IAM Role to the Instance Profile
Write-Host "Attaching IAM Role to Instance Profile"
aws iam add-role-to-instance-profile `
    --instance-profile-name $InstanceProfileName `
    --role-name $RoleName | Out-Null
Start-Sleep -Seconds 5

Write-Host "EC2 instance launched in $REGION using AMI $AMI_ID..."
Write-Host "Public IP of the instance: $public_ip..."