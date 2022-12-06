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

import unittest
import uuid
from qumulo.rest_client import RestClient

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


class TestDeployClusterUsingCloudQ(unittest.TestCase):
    QUMULO_CLUSTER_NODES = 4

    @classmethod
    def setUpClass(cls):
        cls.vpc_executor = TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="terraform_multi_az.tfvars",
            terraform_vars={"execution_id": str(uuid.uuid4())},
            module_path="tests/vpc-terraform",
            log_level=TerraformLogLevel.INFO,
        )
        cls.vpc_executor.deploy()
        cls.outputs = cls.vpc_executor.output()

    def verify_cluster_configuration(self, host: str, password: str):
        rest_client = RestClient(address=host, port=8000)
        rest_client.login(username="admin", password=password)
        version = rest_client.version.version()

        self.assertIsNotNone(version["revision_id"])
        self.assertEqual("release", version["flavor"])

        nodes = rest_client.cluster.list_nodes()

        self.assertEqual(self.QUMULO_CLUSTER_NODES, len(nodes))
        for node in nodes:
            self.assertEqual("online", node["node_status"])

    def test_multi_az_min_path(self):
        cluster_password = f"8_M(p_{str(uuid.uuid4())}"
        executor = TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="terraform_tests.tfvars",
            terraform_vars={
                "deployment_name": f"cloud-q-test-multi-az-{uuid.uuid4()}"[:32],
                "aws_vpc_id": self.outputs["vpc_id"],
                "private_subnet_id": ",".join(self.outputs["private_subnet_ids"]),
                "public_subnet_id": ",".join(self.outputs["public_subnet_ids"]),
                "q_cluster_admin_password": cluster_password,
            },
            module_path=".",
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
            self.verify_cluster_configuration(
                host=outputs["qumulo_nlb_dns"], password=cluster_password
            )

        finally:
            executor.destroy()

    def test_single_az_min_path(self):
        cluster_password = f"8_M(p_{str(uuid.uuid4())}"
        executor = TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="terraform_tests.tfvars",
            terraform_vars={
                "deployment_name": f"cloud-q-test-single-az-{uuid.uuid4()}"[:32],
                "aws_vpc_id": self.outputs["vpc_id"],
                "private_subnet_id": self.outputs["private_subnet_ids"][0],
                "public_subnet_id": self.outputs["public_subnet_ids"][0],
                "q_node_count": self.QUMULO_CLUSTER_NODES,
                "q_cluster_admin_password": cluster_password,
            },
            module_path=".",
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
            self.verify_cluster_configuration(
                host=outputs["qumulo_nlb_dns"], password=cluster_password
            )
        finally:
            executor.destroy()

    @classmethod
    def tearDownClass(cls):
        cls.vpc_executor.destroy()
