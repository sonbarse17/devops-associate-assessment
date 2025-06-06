# DevOps Associate Assessment

A DevOps assessment project demonstrating infrastructure as code, monitoring, and logging using AWS, Terraform, Docker, and observability tools.

## Architecture

- **Infrastructure**: AWS EC2 (t2.micro) and S3 bucket with versioning
- **Monitoring**: CloudWatch CPU alarms and Prometheus metrics
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Web Stack**: Nginx + Redis
- **CI/CD**: GitHub Actions for Terraform validation

## Installation

### Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.6.0
- Docker and Docker Compose
- Git

### Deployment Steps

**1. Clone and Setup**
```bash
git clone <repository-url>
cd devops-associate-assessment

# Make scripts executable
chmod +x cloudwatch-alarm.sh
```

**2. Deploy Infrastructure**
```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy AWS resources
terraform apply
# Type 'yes' when prompted

# Note the outputs (instance_id and public_ip)
terraform output
```

**3. Update Configuration Files**
```bash
# Update cloudwatch-alarm.sh with actual values
INSTANCE_ID=$(terraform output -raw instance_id)
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:123456789012:YourTopic"  # Replace with your SNS topic

# Update prometheus.yml with EC2 public IP
EC2_IP=$(terraform output -raw public_ip)
sed -i "s/X.X.X.X/$EC2_IP/g" prometheus.yml
```

**4. Deploy Application Stack**
```bash
# Start all services
docker-compose up -d

# Verify services are running
docker-compose ps

# Check service health
docker-compose logs web
docker-compose logs elasticsearch
```

**5. Configure Monitoring**
```bash
# Create SNS topic (optional)
aws sns create-topic --name DevOpsAlerts --region us-east-1

# Set up CloudWatch alarm
./cloudwatch-alarm.sh

# Verify alarm creation
aws cloudwatch describe-alarms --alarm-names "HighCPUAlarm"
```

**6. Verification**
```bash
# Test web service
curl http://localhost:8080

# Check Elasticsearch
curl http://localhost:9200/_cluster/health

# Access Kibana (in browser)
# http://localhost:5601

# Check Prometheus targets (if running)
# http://localhost:9090/targets
```

## Configuration

### AWS Resources
- **EC2**: Amazon Linux 2, auto-assigned public IP
- **S3**: `devops-assoc-bucket` with versioning enabled
- **CloudWatch**: CPU utilization alarm (80% threshold)

### Docker Services
- **Nginx**: Web server with health checks
- **Redis**: Data caching
- **ELK Stack**: Centralized logging pipeline
- **Logstash**: Processes `/var/log/app.log`

### Monitoring
- **CloudWatch**: Instance CPU monitoring with SNS alerts
- **Prometheus**: 15s scrape interval on port 9100

## Files

```
├── ec2.tf, s3.tf, provider.tf    # Terraform AWS resources
├── docker-compose.yml            # Multi-service container setup
├── cloudwatch-alarm.sh           # Monitoring configuration
├── prometheus.yml                # Metrics collection config
├── logstash.conf                 # Log processing pipeline
└── .github/workflows/ci.yml      # CI/CD validation
```

## Troubleshooting

```bash
# Check Terraform outputs
terraform output

# View service status
docker-compose ps

# Check service logs
docker-compose logs [service-name]

# Test connectivity
curl http://localhost:8080
curl http://localhost:9200/_cluster/health
```

## Cleanup Procedures

### Complete Cleanup (Recommended Order)

**1. Stop and Remove Docker Services**
```bash
# Stop all running containers
docker-compose down

# Remove containers, networks, and volumes
docker-compose down -v

# Remove images (optional)
docker-compose down --rmi all

# Clean up unused Docker resources
docker system prune -a
docker volume prune
```

**2. Remove CloudWatch Resources**
```bash
# Delete CloudWatch alarm
aws cloudwatch delete-alarms --alarm-names "HighCPUAlarm"

# Delete SNS topic (if created)
aws sns delete-topic --topic-arn "arn:aws:sns:us-east-1:123456789012:DevOpsAlerts"

# Verify deletion
aws cloudwatch describe-alarms --alarm-names "HighCPUAlarm"
```

**3. Destroy Terraform Infrastructure**
```bash
# Review resources to be destroyed
terraform plan -destroy

# Destroy all AWS resources
terraform destroy
# Type 'yes' when prompted

# Verify destruction
aws ec2 describe-instances --filters "Name=tag:Environment,Values=DevOpsTest"
aws s3 ls | grep devops-assoc-bucket
```

**4. Clean Local Files (Optional)**
```bash
# Remove Terraform state files
rm -rf .terraform/
rm terraform.tfstate*

# Remove Docker volumes
docker volume ls | grep devops
docker volume rm $(docker volume ls -q | grep devops)
```

### Partial Cleanup Options

**Stop Services Only (Keep Infrastructure)**
```bash
# Stop containers but keep infrastructure
docker-compose stop

# Start again later
docker-compose start
```

**Remove Only Specific Resources**
```bash
# Remove specific Terraform resource
terraform destroy -target=aws_instance.web

# Remove specific Docker service
docker-compose rm -s web
```

**Emergency Cleanup (If Terraform Fails)**
```bash
# Manual AWS resource removal
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Environment,Values=DevOpsTest" --query 'Reservations[0].Instances[0].InstanceId' --output text)
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# Force remove S3 bucket (delete contents first)
aws s3 rm s3://devops-assoc-bucket --recursive
aws s3 rb s3://devops-assoc-bucket
```

### Verification Commands

**Confirm Complete Cleanup**
```bash
# Check no AWS resources remain
aws ec2 describe-instances --filters "Name=tag:Environment,Values=DevOpsTest"
aws s3 ls | grep devops-assoc-bucket
aws cloudwatch describe-alarms --alarm-names "HighCPUAlarm"

# Check no Docker resources remain
docker ps -a
docker images
docker volume ls
docker network ls

# Check local files
ls -la terraform.tfstate*
ls -la .terraform/
```
## CI/CD Pipeline
The GitHub Actions workflow in .github/workflows/ci.yml automatically validates Terraform configurations when code is pushed to the main branch or when a pull request is created.

## Notes
- All AWS resources are tagged with Environment = "DevOpsTest" for easy identification and cleanup.
- The ELK stack is configured to collect logs from /var/log/app.log.
- The CloudWatch alarm triggers when CPU utilization exceeds 80% for 5 consecutive minutes.
- Prometheus is configured to scrape metrics from the EC2 instance every 15 seconds.
