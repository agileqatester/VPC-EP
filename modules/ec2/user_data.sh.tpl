#!/bin/bash
# user_data.sh - S3-based setup for private EC2

# Variables passed from Terraform
BUCKET_NAME="${s3_bucket_name}"
HOSTNAME="${hostname}"
AWS_REGION="${aws_region}"

# Set hostname
hostnamectl set-hostname $HOSTNAME

# Configure timezone
timedatectl set-timezone UTC

# Create log file early
LOG_FILE="/var/log/s3-setup.log"
mkdir -p /var/log
touch $LOG_FILE

# Function to log with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a $LOG_FILE
}

# Redirect stdout and stderr to log file
exec 1> >(tee -a $LOG_FILE)
exec 2>&1

log_message "=== Starting S3-based setup ==="
log_message "Bucket: $BUCKET_NAME"
log_message "Hostname: $HOSTNAME"
log_message "Region: $AWS_REGION"

# Ensure SSM agent is running
log_message "Starting SSM agent..."
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure AWS CLI region
log_message "Configuring AWS CLI..."
mkdir -p /home/ec2-user/.aws
cat > /home/ec2-user/.aws/config << EOF
[default]
region = $AWS_REGION
output = json
EOF
chown -R ec2-user:ec2-user /home/ec2-user/.aws

# Wait for VPC endpoints and metadata service to be ready
log_message "Waiting for VPC endpoints to be ready..."
sleep 90

# Test Instance Metadata Service
log_message "Testing Instance Metadata Service..."
if curl -s -m 5 http://169.254.169.254/meta-data/instance-id > /dev/null; then
    INSTANCE_ID=$(curl -s http://169.254.169.254/meta-data/instance-id)
    log_message "✓ Metadata service accessible, Instance ID: $INSTANCE_ID"
else
    log_message "✗ Metadata service not accessible"
fi

# Test DNS resolution
log_message "Testing DNS resolution..."
if nslookup s3.amazonaws.com > /dev/null 2>&1; then
    log_message "✓ DNS resolution working"
else
    log_message "✗ DNS resolution failed"
fi

# Test S3 endpoint resolution
log_message "Testing S3 endpoint resolution..."
S3_ENDPOINT="s3.$AWS_REGION.amazonaws.com"
if nslookup $S3_ENDPOINT > /dev/null 2>&1; then
    log_message "✓ S3 endpoint resolution working: $S3_ENDPOINT"
else
    log_message "✗ S3 endpoint resolution failed: $S3_ENDPOINT"
fi

# Test VPC endpoint
log_message "Testing VPC S3 endpoint..."
VPC_S3_ENDPOINT="s3.$AWS_REGION.amazonaws.com"
if dig +short $VPC_S3_ENDPOINT | grep -E '^10\.' > /dev/null; then
    log_message "✓ Using VPC S3 endpoint (private IP)"
else
    log_message "! S3 endpoint may not be using VPC endpoint"
fi

# Test IAM credentials
log_message "Testing IAM credentials..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    CALLER_IDENTITY=$(aws sts get-caller-identity)
    log_message "✓ IAM credentials working: $CALLER_IDENTITY"
else
    log_message "✗ IAM credentials failed"
fi

# S3 access testing (commented nginx parts for now)
# log_message "=== Testing S3 Access ==="
# AWS_OUTPUT=$(aws s3 ls s3://$BUCKET_NAME/ --debug 2>&1)
# ...

# -----------------------------
# Python HTTP Server for training
# -----------------------------
log_message "Starting Python HTTP server for training..."
WWW_DIR="/home/ec2-user/www"
mkdir -p $WWW_DIR
echo "<h1>Hello from EC2!</h1>" > $WWW_DIR/index.html

# Run in background - bind to all interfaces (0.0.0.0)
nohup python3 -m http.server ${app_port} --bind 0.0.0.0 --directory $WWW_DIR &

log_message "✓ Python HTTP server started at port $${app_port} serving $WWW_DIR"

# Create comprehensive status file
cat > /home/ec2-user/setup-status.txt << EOF
=== EC2 Instance Setup Status ===
Setup Time: $(date)
Hostname: $HOSTNAME
Instance ID: $${INSTANCE_ID:-"Unknown"}
S3 Bucket: $BUCKET_NAME
AWS Region: $AWS_REGION

Python HTTP server: running on port $${app_port}
Setup Status: SUCCESS (training mode)

Log File: $LOG_FILE
EOF
chown ec2-user:ec2-user /home/ec2-user/setup-status.txt

# Create welcome message
cat > /etc/motd << EOF
=================================================
  Private EC2 Instance - Training Mode
  Hostname: $HOSTNAME
  Python HTTP Server running on port $${app_port}
  Access Methods:
    - EIC Endpoint SSH
    - Session Manager
  Check ~/setup-status.txt for summary
=================================================
EOF

log_message "=== Setup completed (training mode) ==="
