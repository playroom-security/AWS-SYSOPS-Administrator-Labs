# Create, Manage, and Troubleshoot AWS CloudFormation

## Overview
AWS CloudFormation is a service that allows you to create and manage AWS infrastructure deployments predictably and repeatedly. With AWS CloudFormation, you can define your infrastructure in a JSON or YAML file, and then use the AWS CloudFormation console, API, or CLI to create, update, and delete your stacks. This lab will guide you through the process of creating, managing, and troubleshooting AWS CloudFormation.

## Prerequisites
There are no prerequisites for this lab.

## How to Create a CloudFormation template
We will be looking at different features that makes up a CloudFormation template. The following is a sample CloudFormation template that creates an EC2 instance:

```yaml
Resources:
  MyEC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c55b159cbfafe1f0
      InstanceType: t2.micro
      SecurityGroupIds:
        - sg-0123456789abcdef0
      SubnetId: subnet-0123456789abcdef0
```

Let's break down the different sections of the template:

- **Resources**: This section defines the resources that will be created by the CloudFormation template. In this case, we are creating an EC2 instance.
- **MyEC2Instance**: This is the name of the resource. It can be any name that you choose.
- **Type**: This is the type of resource that will be created. In this case, it is an EC2 instance.
- **Properties**: This is a list of properties that will be applied to the resource. In this case, we are specifying the AMI ID, instance type, security group ID, and subnet ID.

