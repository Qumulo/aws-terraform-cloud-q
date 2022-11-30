import unittest
import uuid

from tests.utils import TerraformExecutor, TerraformLogLevel


class TestDeployVPC(unittest.TestCase):
    def test_happy_path(self):
        executor = TerraformExecutor(
            terraform_workspace='test',
            terraform_vars_file='terraform.tfvars',
            terraform_vars={"execution_id": str(uuid.uuid4())},
            module_path='tests/vpc-terraform',
            log_level=TerraformLogLevel.INFO,
        )
        try:
            executor.deploy()
        finally:
            executor.destroy()
