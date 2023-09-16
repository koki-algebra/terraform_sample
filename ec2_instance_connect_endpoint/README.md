# EC2 Instance Connect Endpoint Sample
プライベートサブネットに配置されている EC2 Instance に EC2 Instance Connect Endpoint を用いて接続する.

## Connect to EC2 Instance by EC2 Instance Connect Endpoint
以下のコマンドで接続可能.
```
aws ec2-instance-connect ssh --instance-id <instance-id> --connection-type eice --region us-east-1
```
