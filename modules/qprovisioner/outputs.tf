#MIT License

#Copyright (c) 2022 Qumulo, Inc.

#Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal 
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all 
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
#SOFTWARE.

output "status" {
  description = "If the provisioner instance completed secondary provisioning of the cluster = Success/Failure"
  value       = var.check_provisioner_shutdown ? nonsensitive(data.aws_ssm_parameter.qprovisioner[0].value) == "Shutting down provisioning instance" ? "Success" : "FAILURE" : "Validate secondary provisioning of the cluster completed.  Verify EC2 Instance ID ${aws_instance.provisioner.id} auto shutdown or check Parameter Store ${aws_ssm_parameter.last-run-status.arn}"
}