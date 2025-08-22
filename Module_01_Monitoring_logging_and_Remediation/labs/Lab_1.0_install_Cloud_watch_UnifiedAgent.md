# Installing the Cloudwatch Unified Agent

After setting up the infrasture using the [setup_script](/Module_01_Monitoring_logging_and_Remediation/labs/setup.sh). You should have
- A newly created VPC
- One Public subnet
- One private subnet
- One VPC attached Internet Gateway
- Public and Private route table
- One security group for the ec2 instance
- One Ec2 instance
- One SSH keypair 

You should be able to use the Secure Shell protocol (SSH) to login into the ec2 instance.

The following commands would be ran on your SSH terminal to install the ``CloudWatch Unified Agent``.

If you already have an ec2 instance running and you want to install the CloudWatch agen, follow this steps below to get started with creating an Instance profile :

```bash

Create an IAM role to run the CloudWatch agent on your EC2 instance

Complete the following steps:

- Open the AWS Identify and Access Management (IAM) console.
- In the navigation pane, choose Roles.
- Choose Create role.
- For Choose the service that will use this role, choose EC2.
- Choose Next: Permissions.
- In the list of policies, select CloudWatchAgentServerPolicy.
- Choose Next: Tags, and then choose Next: Review.
- For Role name, enter a name for the role, such as CloudWatchAgentServerRole.
(Optional) Provide a role description.
- Confirm that CloudWatchAgentServerPolicy appears next to Policies.
- Choose Create role.
- Attach the new IAM role to the EC2 instance.
```

Then follow this for the install process

---

## Download and install the unified CloudWatch agent
**Linux EC2 instance**

### Complete the following steps:

**To download the CloudWatch agent, run the following command in your terminal:**

```bash
wget https://s3.region.amazonaws.com/us-east-1/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
```
Note: In the preceding command, replace ``us-east-1`` with your preferred AWS Region.

- **To install the CloudWatch agent, run the following command in your terminal:**

```bash
sudo rpm -U ./amazon-cloudwatch-agent.rpm
```

### Create the agent configuration file
**To create the agent configuration file, use the wizard. Then, manually edit the file to add or remove metrics or logs.**

Run the following command:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

```
After running the above command we need to congihure the following:

- On which OS are you planning to use the agent? (Linux)
- Are you using EC2 or On-Premises hosts? (EC2)
- Which user are you planning to run the agent? (root)
- Do you want to turn on the StatsD daemon? (yes)
StatsD is a popular open-source solution that can gather metrics from a wide variety of applications.

- Which port do you want the StatsD daemon to listen to? (8125)
- What is the collection interval for the StatsD daemon? (10s)
- What is the aggregation interval for metrics collected by StatsD daemon?(the 60s)
- Do you want to monitor metrics from CollectD?(No)
- Do you want to monitor any host metrics? e.g. CPU, memory, etc. (yes)
**We will be using this host metrics to create some Dashboards in the other sections.**

- Do you want to monitor CPU metrics per core? (yes)
- Do you want to add ec2 dimensions (ImageId, InstanceId, InstanceType, AutoScalingGroupName) into all of your metrics if the info is available? (yes)
- Do you want to aggregate ec2 dimensions (InstanceId)? (yes)
- Would you like to collect your metrics at high resolution (sub-minute resolution)? This enables sub-minute resolution for all metrics, but you can customize for specific metrics in the output JSON file. (60s)
- Which default metrics config do you want? (Standard)

- Are you satisfied with the above config? (yes)
- Do you have any existing CloudWatch Log Agent? (no)
- Do you want to monitor any log files? (yes)
Because in this tutorial we will monitor our Apache log file(e.g. error_log)

- Log file path: (/var/log/httpd/error_log)
default choice: (e.g. CloudWatchDemo)
- Log stream name: ({instance_id})
- Log Group Retention in days (2)
- Do you want to specify any additional log files to monitor? (no)
- Do you want to store the config in the SSM parameter store? (no)
```