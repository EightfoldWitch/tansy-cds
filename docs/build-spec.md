# Cloud Infrastructure Deployment Specification

## 📋 System Overview
This system is a hybrid cloud-native architecture designed to support data ingestion, processing, and web application delivery. It includes the following components:

- **VPC** with 3 public and 3 private subnets
- **Elastic Beanstalk applications**:
  - `influxdb`: InfluxDB (v2.7.11) in private subnet
  - `rabbitmq`: RabbitMQ (v4.1.0-management) in public/private subnets
  - `data_proc`: AWS Linux Docker-based scalable EC2 (1-5 instances) in private subnet
  - `front_srv`: Node.js (nodejs:lts) Docker-based scalable EC2 (1-5 instances) in public subnet
- **API Gateway** routing to `front_srv`
- **Amplify Hosting** for static files in S3, mounted under `/static`
- **Route 53** DNS setup for API and static site
- **VPN Access** to private subnets via AWS Client VPN

All resources are tagged with: `dev-deploy-script = 0`

---

## 🔐 IAM Roles and Required Permissions

### Elastic Beanstalk Service Role
- **Role Name:** `aws-elasticbeanstalk-service-role`
- **Permissions:**
  - `elasticbeanstalk:*`
  - `ec2:*`
  - `elasticloadbalancing:*`
  - `cloudwatch:*`
  - `autoscaling:*`
  - `s3:GetObject`
  - `logs:*`

### Instance Profile Role (for EC2)
- **Role Name:** `aws-elasticbeanstalk-ec2-role`
- **Permissions:**
  - `AmazonEC2ContainerRegistryReadOnly`
  - `AmazonS3ReadOnlyAccess`
  - `CloudWatchAgentServerPolicy`
  - Custom policy for reading application zips from S3

### API Gateway
- No role needed for proxying to `front_srv` public endpoint

### Amplify Hosting
- **IAM Role:** `AmplifyServiceRole`
- **Permissions:**
  - `amplify:*`
  - `s3:*` for target bucket

### VPN Service
- Depends on authentication type:
  - **Mutual Authentication**: ACM certificate with client-side key
  - **Directory Service Authentication**: Active Directory configured with associated permissions

---

## 🔌 Component Connections

| Component       | Connects To            | Method                |
|----------------|------------------------|------------------------|
| `influxdb`     | Private subnets        | EB + private ELB       |
| `rabbitmq`     | Public/private subnets | EB + dual ELB          |
| `data_proc`    | Private subnets        | EB + S3 zip + auto-scaling |
| `front_srv`    | Public subnets         | EB + S3 zip + API Gateway |
| API Gateway    | `front_srv` app        | HTTP proxy             |
| Amplify        | S3 static site         | CDN hosting            |
| Route 53       | Amplify + front_srv    | Alias DNS records      |
| VPN            | Private subnets        | VPC route table + client auth |

---

## 🛠 Manual Creation Steps

1. **VPC Setup**:
   - Create a VPC, 3 public and 3 private subnets
   - Configure NAT Gateway and routing tables

2. **IAM Roles**:
   - Create Elastic Beanstalk service role and EC2 instance profile role
   - Grant necessary S3, EC2, ECR, CloudWatch permissions

3. **Elastic Beanstalk Environments**:
   - Create environments for each app
   - Set instance type, scaling rules, and Docker images
   - Point to S3 zips where applicable

4. **API Gateway**:
   - Create a REST API
   - Define resources and methods (POST/GET)
   - Use HTTP proxy to connect to `front_srv` endpoint

5. **Amplify Hosting**:
   - Create Amplify app and branch
   - Connect to static S3 bucket

6. **Route 53 DNS**:
   - Create hosted zone records
   - Set alias records to ELB (front_srv) and Amplify app

7. **VPN Setup**:
   - Provision Client VPN endpoint
   - Attach authentication and route to private subnets

---

## ✅ Requirements Summary

| Resource Type        | Requirements                                |
|---------------------|---------------------------------------------|
| EC2 Instances        | `m5.large`, private/public networking       |
| IAM Roles            | Elastic Beanstalk service + EC2 roles       |
| Docker Images        | InfluxDB 2.7.11, RabbitMQ 4.1.0-management, Node.js LTS |
| S3                   | Application zips, static files              |
| API Gateway          | REST API, HTTP proxy integration            |
| Amplify Hosting      | Static site routing under `/static`         |
| Route 53             | Public DNS records                          |
| VPN                  | Client VPN access to private subnets        |

---

Please ensure that application code, zipped for deployment, is available in S3 with appropriate access policies.

For full automation, the CloudFormation script should be launched via AWS CLI or Console, followed by VPN and Amplify CLI configuration.

