# MIT License

# Copyright (c) 2022 Qumulo, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
from abc import ABC, abstractmethod
import subprocess
from typing import Dict
import unittest
import uuid

import requests
from retry import retry

from tests.utils import TerraformExecutor, TerraformLogLevel


class TestDeployVPC(unittest.TestCase):
    def test_happy_path(self):
        executor = TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="terraform_single_az.tfvars",
            terraform_vars={"execution_id": f"foundation-test-{uuid.uuid4()}"[:32]},
            module_path="tests/vpc-terraform",
            log_level=TerraformLogLevel.INFO,
        )
        try:
            results = executor.deploy()
            self.assertEqual(
                0,
                results.returncode,
                msg=f"Deployment was not successful, check the session output",
            )
            outputs = executor.output()
            self.assertIsNotNone(outputs["vpc_id"])
            self.assertEqual(1, len(outputs["private_subnet_ids"]))
            self.assertEqual(1, len(outputs["public_subnet_ids"]))
        finally:
            executor.destroy()


class BaseClusterTests(ABC, unittest.TestCase):
    # Tell pytest to skip this test class
    __test__ = False

    CLUSTER_PASSWORD = f"8_M(p_{str(uuid.uuid4())}"
    QUMULO_CLUSTER_NODES = 4

    vpc_executor_deploy_result: subprocess.CompletedProcess
    vpc_executor_outputs: Dict[str, str]
    qumulo_executor_deploy_result: subprocess.CompletedProcess
    qumulo_executor_outputs: Dict[str, str]

    @classmethod
    def setUpClass(cls):
        if cls is BaseClusterTests:
            raise unittest.SkipTest("Skip BaseClusterTests base class")

        # Deploy the VPC
        cls.vpc_executor = TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="terraform_multi_az.tfvars",
            terraform_vars={"execution_id": str(uuid.uuid4())},
            module_path="tests/vpc-terraform",
            log_level=TerraformLogLevel.INFO,
        )
        cls.vpc_executor_deploy_result = cls.vpc_executor.deploy()
        cls.vpc_executor_outputs = cls.vpc_executor.output()

        # Deploy the Qumulo file system
        cls.qumulo_executor = cls.create_qumulo_terraform_executor()
        cls.qumulo_executor_deploy_result = cls.qumulo_executor.deploy()
        cls.qumulo_executor_outputs = cls.qumulo_executor.output()

    @classmethod
    def tearDownClass(cls):
        if cls is BaseClusterTests:
            raise unittest.SkipTest("Skip BaseClusterTests base class")

        # Clean up the Qumulo file system and AWS VPC
        cls.qumulo_executor.destroy()
        cls.vpc_executor.destroy()

    def setUp(self) -> None:
        self.assertEqual(
            0,
            self.vpc_executor_deploy_result.returncode,
            msg=f"AWS VPC deployment was not successful. Check the session output.",
        )
        self.assertEqual(
            0,
            self.qumulo_executor_deploy_result.returncode,
            msg=f"Qumulo file system deployment was not successful. Check the session output.",
        )

    @classmethod
    @abstractmethod
    def create_qumulo_terraform_executor(cls) -> TerraformExecutor:
        ...

    # TEST CASES

    def test_http_ui(self):
        @retry(requests.exceptions.Timeout, delay=1, tries=180)
        def fetch_ui() -> requests.Response:
            return requests.get(
                f'{self.qumulo_executor_outputs["qumulo_public_url"]}/version',
                verify=False,
            )

        self.assertIsNotNone(fetch_ui().json().get("revision_id"))

    def test_terraform_outputs(self):
        self.assertEqual(
            "Success", self.qumulo_executor_outputs["qumulo_cluster_provisioned"]
        )


class TestSingleAZ(BaseClusterTests):
    __test__ = True

    @classmethod
    def create_qumulo_terraform_executor(cls) -> TerraformExecutor:
        # Create a single AZ file system TerraformExecutor
        return TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="terraform_tests.tfvars",
            terraform_vars={
                "deployment_name": "cloud-q-test-single-az",
                "aws_vpc_id": cls.vpc_executor_outputs["vpc_id"],
                "private_subnet_id": cls.vpc_executor_outputs["private_subnet_ids"][0],
                "public_subnet_id": cls.vpc_executor_outputs["public_subnet_ids"][0],
                "q_node_count": cls.QUMULO_CLUSTER_NODES,
                "q_cluster_admin_password": cls.CLUSTER_PASSWORD,
            },
            module_path=".",
            log_level=TerraformLogLevel.INFO,
        )


class TestMultiAZ(BaseClusterTests):
    __test__ = True

    @classmethod
    def create_qumulo_terraform_executor(cls) -> TerraformExecutor:
        # Create a multi AZ file system TerraformExecutor
        return TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="terraform_tests.tfvars",
            terraform_vars={
                "deployment_name": "cloud-q-test-multi-az",
                "aws_vpc_id": cls.vpc_executor_outputs["vpc_id"],
                "private_subnet_id": ",".join(
                    cls.vpc_executor_outputs["private_subnet_ids"]
                ),
                "public_subnet_id": ",".join(
                    cls.vpc_executor_outputs["public_subnet_ids"]
                ),
                "q_cluster_admin_password": cls.CLUSTER_PASSWORD,
            },
            module_path=".",
            log_level=TerraformLogLevel.INFO,
        )
