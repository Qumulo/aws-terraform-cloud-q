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

import unittest
import uuid

from tests.utils import TerraformExecutor, TerraformLogLevel


class TestDeployVPC(unittest.TestCase):
    def test_happy_path(self):
        executor = TerraformExecutor(
            terraform_workspace='test',
            terraform_vars_file='terraform_single_az.tfvars',
            terraform_vars={"execution_id": str(uuid.uuid4())},
            module_path='tests/vpc-terraform',
            log_level=TerraformLogLevel.INFO,
        )
        try:
            results = executor.deploy()
            self.assertEqual(0, results.returncode, msg=f'Deployment was not successful, check the session output')
            outputs = executor.output()
            print(f'outputs are {outputs}')
            self.assertIsNotNone(outputs['vpc_id'])
            self.assertEqual(1, len(outputs['private_subnet_ids']))
            self.assertEqual(0, len(outputs['public_subnet_ids']))
        finally:
            executor.destroy()

class TestDeployClusterUsingCloudQ(unittest.TestCase):
    def test_happy_path(self):
        executor = TerraformExecutor(
            terraform_workspace='test',
            terraform_vars_file='terraform_tests.tfvars',
            terraform_vars={},
            module_path='.',
            log_level=TerraformLogLevel.INFO,
        )
        try:
            results = executor.deploy()
            self.assertEqual(0, results.returncode, msg=f'Deployment was not successful, check the session output')
        finally:
            executor.destroy()
