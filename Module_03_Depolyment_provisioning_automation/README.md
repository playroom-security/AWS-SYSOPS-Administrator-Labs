# Module 03 - Deployment Provisioning Automation

---

# Task Statement 3.1:
- Create and manage AMIs (for example, EC2 Image Builder).
- Create, manage, and troubleshoot AWS CloudFormation.
- Provision resources across multiple AWS Regions and accounts (for example,
- AWS Resource Access Manager [AWS RAM], CloudFormation StackSets, IAM
cross-account roles).
- Select deployment scenarios and services (for example, blue/green, rolling,
canary).
- Identify and remediate deployment issues (for example, service quotas, subnet
sizing, CloudFormation errors, permissions).

## Task Statement 3.2: Automate manual or repeatable processes.
- Use AWS services (for example, Systems Manager, CloudFormation) to automate deployment processes.
- Implement automated patch management.
- Schedule automated tasks by using AWS services (for example, EventBridge, AWS Config).

---

## Lab Objective

The objective of this lab is to demonstrate how to automate the deployment of a new AWS account using AWS CloudFormation. The lab will demonstrate how to use AWS CloudFormation to create a new AWS account, and then use the AWS CLI to configure the new account.

## Lab Environment

This lab requires an AWS account with administrator access. If you do not have an AWS account, please follow the instructions in the [Prerequisites](../Prerequisites/README.md) section before proceeding with the lab.

## Lab Setup

### Step 1: Clone the GitHub Repository

Clone the GitHub repository containing the lab files to your local machine using the following command:

```bash
git clone https://github.com/aws-samples/aws-sysops-workshops.git
```

### Step 2: Launch the CloudFormation Stack

1. Open the AWS CloudFormation console at [https://console.aws.amazon.com/cloudformation](https://console.aws.amazon.com/cloudformation).
2. In the **Create stack** section, click **With new resources (standard)**.
3. In the **Specify template** section, select the **Upload a template file** option.
4. Click **Choose file** and select the `templates/lab-03-deployment-provisioning-automation.yaml` file from the cloned GitHub repository.
5. In the **Specify stack details** section, enter a **Stack name** and click **Next**.
6. In the **Parameters** section, enter the following values:
   - **AdminEmail**: Enter the email address of the account administrator.
   - **AccountName**: Enter the name of the new AWS account.
7. Click **Next**.
8. In the **Configure stack options** section, select the **Disable rollback** option and click **Next**.
9. In the **Review** section, review the stack details and click **Create stack**.
10. Wait for the stack to be created. You can monitor the status of the stack in the **Status** column of the CloudFormation console.
11. Once the stack is created, click the **Outputs** tab to view the output values from the stack.
12. Copy the values of the **AccountId** and **AccountEmail** outputs to a text editor.
13. Open the text editor and save the file as `outputs.txt`.

### Step 3: Configure the New AWS Account
