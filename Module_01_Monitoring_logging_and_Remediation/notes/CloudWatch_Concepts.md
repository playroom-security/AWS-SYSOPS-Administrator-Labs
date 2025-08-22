## Amazon CloudWatch: 

This is a monitoring and observability service that provides data and actionable insights to monitor your applications, respond to system-wide performance changes, and optimize resource utilization. 

You can use CloudWatch to collect and track metrics, collect and monitor log files, and set alarms. It's essential for understanding the health and performance of your AWS resources and applications.

By default, EC2 send host-level metrics like CPU, network, disk, and status checks to Cloudwatch

# Key Concepts:

## Amazon CloudWatch metrics: 

It automatically collects metrics from some integrated AWS services like EC2 instances, Amazon EBS and Amazon RDS databases instances into an organizaed dashboards and or alarms.

`Metrics are time ordered set of data points`

The CloudWatch agent installed on ec2 is used to send operating system-level metrics like memory usage, processes, and CPU idle time. 

`Log Events:` Event message and timestamp, e.g events from an Apache log.

`Log Stream:` Sequence of log events from the same source, like an Apache log coming from a specific EC2 instance. Each log stream must belong to a log group.

`Log Group:` They are a collections of Log stream from diferent sources. You might have different ec2 instances sreaming logs to Cloudwatch. They are captured and placed into one Log group.


## Amazon CloudWatch Logs

It is integrated with AWS services like, EC2, VPC flow logs, Lambda, Cloudtrail, R53 and many other

CloudWatch logs is a product which can store, manage and provide access to logging data for on-premises and AWS environments including systems and applications.

it can also via `subscription filters` stream the data to Lambda, Elasticsearch, Kinesis streams and firehose for further delivery.

`Metric filters` can be used to generate Metrics within Cloudwatch, alarms and eventual events within Eventbridge.


## Amazon Cloudwatch Alarms: 

By using Amazon CloudWatch alarms you can set alarms based on metrics collected. Alarms can be configured to send notifications to Amazon SNS topics or initiate some kind of Auto scaling actions.

