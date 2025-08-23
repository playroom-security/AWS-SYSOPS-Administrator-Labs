#!/bin/bash

set +e 

# Clean up
echo "Cleaning up resources..."
# Read the saved IDs from the file
while IFS= read -r line; do
    if [[ $line == VPC* ]]; then
        vpcId=$(echo $line | cut -d ' ' -f 3)
    elif [[ $line == Private* ]]; then
        SubnetIdPrivateSubnet=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == Public* ]]; then
        SubnetIdPublicSubnet=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == Internet* ]]; then
        InternetGatewayId=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == Route* ]]; then
        RouteTableId=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == Security* ]]; then
        SecurityGroupId=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == Instance* ]]; then
        InstanceId=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == Key* ]]; then
        KeyName=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == Role* ]]; then
        RoleName=$(echo $line | cut -d ' ' -f 4)
    elif [[ $line == InstanceProfile* ]]; then
        InstanceProfileName=$(echo $line | cut -d ' ' -f 4)
    else
        echo "Unknown line format: $line"
    fi
done < monitoring-setup.txt
  
export VPC_ID=$vpcId
export PRIVATE_SUBNET_ID=$SubnetIdPrivateSubnet
export PUBLIC_SUBNET_ID=$SubnetIdPublicSubnet
export INTERNET_GATEWAY_ID=$InternetGatewayId
export ROUTE_TABLE_ID=$RouteTableId
export SECURITY_GROUP_ID=$SecurityGroupId
export INSTANCE_ID=$InstanceId
export KEY_NAME=$KeyName
export ROLE_NAME=$RoleName
export INSTANCE_PROFILE_NAME=$InstanceProfileName      

# Delete the resources
aws ec2-instance delete --instance-ids $InstanceId
aws ec2 delete-key-pair --key-name "my-key-pair"
aws ec2 delete-security-group --group-id $SecurityGroupId
aws ec2 disassociate-route-table --subnet-id $SubnetIdPublicSubnet --route-table-id $RouteTableId
aws ec2 delete-route-table --route-table-id $RouteTableId
aws ec2 delete-internet-gateway --internet-gateway-id $InternetGatewayId
aws ec2 detach-internet-gateway --vpc-id $vpcId --internet-gateway-id $InternetGatewayId
aws ec2 delete-subnet --subnet-id $SubnetIdPublicSubnet
aws ec2 delete-subnet --subnet-id $SubnetIdPrivateSubnet
aws ec2 delete-vpc --vpc-id $vpcId 
aws iam delete-role --role-name $RoleName
aws iam delete-instance-profile --instance-profile-name $InstanceProfileName 
echo




