# Replace with your instance ID and SNS topic ARN
INSTANCE_ID="i-06e5735b40ff8dfcd"
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:123456789012:YourTopic"

aws cloudwatch put-metric-alarm \
  --alarm-name "HighCPUAlarm" \
  --alarm-description "Alarm when CPU exceeds 80% for 5 consecutive minutes" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --dimensions Name=InstanceId,Value=$INSTANCE_ID \
  --unit Percent \
  --alarm-actions $SNS_TOPIC_ARN
