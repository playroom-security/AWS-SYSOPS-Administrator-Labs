# Deployment a Hardened Amazon Linux 2 AMI with EC2 Image Builder

![Ec2-Image-Builder](/Assets/ec2-imagebuilder.png)

## Overview

EC2 Image Builder is a fully managed AWS service that helps you to automate the creation, management, and deployment of customized, secure, and up-to-date server images. With EC2 Image Builder, you can create custom AMIs, which are pre-configured with the operating system and software of your choice.
This lab will guide you through the process of creating a hardened Amazon Linux 2 AMI using EC2 Image Builder. The lab will cover the following topics:

- Creating an EC2 Image Builder pipeline
- Creating an EC2 Image Builder recipe
- Creating an EC2 Image Builder distribution configuration
- Creating an EC2 Image Builder image recipe
- Creating an EC2 Image Builder image pipeline
- Creating an EC2 Image Builder image distribution configuration

## Prerequisites

Before you begin this lab, ensure that you have completed the following prerequisites:

- An AWS account with administrator access.
- A choice of supported Linux operating systems (for example, Amazon Linux 2 and 2023, CentOS 7 and 8, Ubuntu 18.04 LTS to Ubuntu 20.04 LTS).

## Step 1: Create an EC2 Image Builder Pipeline

1. Open the EC2 Image Builder console at [https://console.aws.amazon.com/imagebuilder](https://console.aws.amazon.com/imagebuilder).
2. In the navigation pane, choose **Create Image Pipelines**.
3. Choose **Create pipeline**.
4. In the **Create pipeline** dialog box, enter a **Name** for the pipeline.
5. Choose a Description for the pipeline.
6. Leave "Enable enhanced metadata collection" selected under **Enhanced metadata collection(for AMI only)**.
7. You can optionally choose to enable **Enable EC2 Imagescanning** and **Enable ECR container scanning** depending on your requirements. I would recommend leaving these options disabled.
8. Under **Build schedule**, choose **Manual**. You can also optionally choose to enable **Schedule builder**, it runs the pipeline on a schedule.  
9. Choose **Next**.

## Step 2: Choose a Recipe
1. In the **Choose a recipe** section, select **Ceate new recipe**. That would require addtional configuration steps.
2. Under the **Image type**, leave the default **Output type** as **Amazon Managed Image(AMI)**. Feel free to experiment with other output types (Docker Image).
3. Give the recipe a **Name**, and **Vesion**.
4. Under **Base image**, choose **Select managed Images**. This gives you the option to select managed images created by you, shared with you or provided by AWS.
5. Choose **Amazon Linux**.
6. Under **Image origin**, leave the default as **Quick start (Amazon-managed)**.
7. Choose **Amazon Linux 2023 x86**.
8. Under **Instance configuration**, leave everything as defau;t EXCEPT you want to add your **User data** to the instance. You can use the following as a starting point:

```bash
#!/bin/bash
sudo yum update -y
sudo yum install -y aws-cli
```

9. Leave **Working directory** as default. Default path is `/tmp`.
10. Under **Components**, I will select **Build components**. This will allow you to select the components you want to include in the AMI.
11. Under **Build components**, select **Add component**. This will open a new window.
12. In the **Add component** window, choose **Amazon-cloudwatch-agent-linux**, **aws-cli-version-2-linux** and **python-3-linux**. Feel free to add more components as you see fit.
13. Select **Save to recipe**.
14. Under **Add Test component**, I will leave as default.
15. Under **Storage**, I will leave as default. Which would have an 8gb EBS volume attached to the instance. Make sure **Delete on termination** is selected.
16. Select **Next**.

## Step 3: Define Image creation process
1.Under **Type**, I will select the defaults, which is **Default workflows**.
2. Click **Next**.

## Step 4: Define infrastructure configuration - optional
1. Under **Infrastructure configuration**, I will select **Create new infrastructure configuration**. You can as well use the default infrastructure configuration using service defaults which would create an **Instance Profile** for you and set the permissions. 
2. Under the **General** section, I will give it a **Name** and **Description**.
3. Under the **IAM role**, I will select **Create new role**. Since I want the SSM agent to be installed on the instance, I will select the following permissions to be added to the role.
    - **arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore**
    - **arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy** 
    - **arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder**  
will be added to the instance profile. Save the **IAM Rol** and return to the infrastructure configuration and select the newly created role.
4. Under **AWS Infrastructure**, select the **Instance type** as `t2.micro`.
5. You can optionally select a **SNS Topic** to be notified during the buid process. I leave it as default.
6. Under **VPC, subnet, and security group**, I will choose my VPC, a public subnet and a preconfigured **Allowed only trusted Public IP** security group.
7. I will leave everything else as default.
8. Click **Next**.

## Step 5: Define distribution settings - optional
1. Under **Distribution Settings**, I will leave everything as default. But you can experiment with different settings.
2. Click **Next**.

## Step 6: Review and create the pipeline
Review the pipeline and click **Create pipeline**.

![pipeline-created](/Assets/ec2-hardened-img-builder.png)

## Step 7: Run the pipeline
1. Still on the **EC2 Image Builder** console, click **Actions** and select **Run pipeline**.
2. You will get a `Pipeline execution initiated successfully` message.

## Step 8: View the pipeline execution
1. Go to the EC2 Instance console at [https://console.aws.amazon.com/ec2/](https://console.aws.amazon.com/ec2/).
2. On the list of instances, you will see the ``Build instance for <pipeline name>`` instance. Wait for the instance to change to `Testing` status.
You can see the **Image status** as `Building` Under the **Output image** tab in the EC2 Image Builder console.

![image-building-status](/Assets/ec2-img-builder-buiding.png)










## References:

- [EC2 Image Builder](https://docs.aws.amazon.com/imagebuilder/latest/userguide/what-is-imagebuilder.html)
- [EC2 Image Builder Components](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-component.html)
- [EC2 Image Builder Pipelines](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-pipeline.html)
- [EC2 Image Builder Recipes](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-recipe.html)
- [EC2 Image Builder Distribution Configurations](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-distribution-configuration.html)
- [EC2 Image Builder Image Recipes](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-image-recipe.html)
- [EC2 Image Builder Image Pipelines](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-image-pipeline.html)
- [EC2 Image Builder Image Distribution Configurations](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-image-distribution-configuration.html)