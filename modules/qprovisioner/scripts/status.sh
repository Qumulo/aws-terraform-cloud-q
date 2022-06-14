#!/bin/bash -e
maxtime=0
status=$(aws ssm get-parameter --region ${aws_region} --output text --name "/qumulo/${deployment_unique_name}/last-run-status" --query "Parameter.Value")
while [ "$status" == "Shutting down provisioning instance" ] || [ "$status" == "null" ]; do
  echo "Waiting for boot..."
  sleep 10        
  status=$(aws ssm get-parameter --region ${aws_region} --output text --name "/qumulo/${deployment_unique_name}/last-run-status" --query "Parameter.Value")
done
while [ "$status" != "Shutting down provisioning instance" ]; do
  sleep 10
  status=$(aws ssm get-parameter --region ${aws_region} --output text --name "/qumulo/${deployment_unique_name}/last-run-status" --query "Parameter.Value")
  echo $status
  (( maxtime = maxtime + 10 ))
  if [ $maxtime -gt 900 ]; then
    echo "****************Cluster Provisioning FAILED****************"
    echo "AWS Parameter Store /qumulo/${deployment_unique_name}/last-run-status to see what stage it failed at.  You may resolve the issue and manually restart it."
    echo "For more detailed analysis review the AWS provisioning instance ${aws_instance_id} log to troubleshoot"
  fi
done
echo "*****Cluster Successfully Provisioned*****"