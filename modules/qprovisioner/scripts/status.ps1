      $timeout = 0
      $status = aws ssm get-parameter --region ${aws_region} --output text --name "/qumulo/${deployment_unique_name}/last-run-status" --query "Parameter.Value"
      while (($status -eq "Shutting down provisioning instance") -or ($status -eq "null")) {
        Write-Host "Waiting for boot..."
        Start-Sleep -Seconds 10     
        $status=aws ssm get-parameter --region ${aws_region} --output text --name "/qumulo/${deployment_unique_name}/last-run-status" --query "Parameter.Value"
      }
      while ($status -ne "Shutting down provisioning instance") {
        Start-Sleep -Seconds 10   
        $status=aws ssm get-parameter --region ${aws_region} --output text --name "/qumulo/${deployment_unique_name}/last-run-status" --query "Parameter.Value"
        Write-Host $status
        $timeout = $timeout + 10
        if ($timeout -gt 900) {
          Write-Host "****************Cluster Provisioning FAILED****************"
          Write-Host "AWS Parameter Store /qumulo/${deployment_unique_name}/last-run-status to see what stage it failed at.  You may resolve the issue and manually restart it."
          Write-Host "For more detailed analysis review the AWS provisioning instance ${aws_instance_id} log to troubleshoot"
        }
      }
      Write-Host "*****Cluster Successfully Provisioned*****"