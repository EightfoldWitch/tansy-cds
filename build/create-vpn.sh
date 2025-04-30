# Create a Client VPN endpoint
aws ec2 create-client-vpn-endpoint \
  --client-cidr-block 10.8.0.0/22 \
  --server-certificate-arn arn:aws:acm:REGION:ACCOUNT_ID:certificate/YOUR_CERTIFICATE_ID \
  --authentication-options Type=directory-service-authentication,ActiveDirectory=YOUR_DIRECTORY_ID \
  --connection-log-options Enabled=true,CloudwatchLogGroup=log-group,CloudwatchLogStream=log-stream \
  --dns-servers 8.8.8.8 \
  --tag-specifications 'ResourceType=client-vpn-endpoint,Tags=[{Key=dev-deploy-script,Value=0}]' \
  --vpc-id <VPC_ID> \
  --security-group-ids <SG_ID> \