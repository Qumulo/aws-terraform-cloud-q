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

aws_region             = "us-west-2"
deployment_unique_name = "test-sort"
#disk_config = null
disk_config           = "600GiB-AF"
floating_ips_per_node = 3
node_count            = 6

#marketplace_type       = "1TB-Usable-All-Flash"
#marketplace_type = "Custom-1TB-6PB"
marketplace_type = "Specified-AMI-ID"

nodes_per_az = 2

private_subnet_ids = ["subnet-01d76eb8ccdc3f156"]
#private_subnet_ids = ["subnet-01d76eb8ccdc3f156", "subnet-0c8edd3974ebe65c2", "subnet-0e2e94f42d42f23fe", "subnet-0edfe9c88d90d51af"]
#private_subnet_ids = ["subnet-01d76eb8ccdc3f156", "subnet-01d76eb8ccdc3f156", "subnet-0e2e94f42d42f23fe", "subnet-0edfe9c88d90d51af"]

public_subnet_ids = []
#public_subnet_ids = ["subnet-1234567890abcdefg"]
