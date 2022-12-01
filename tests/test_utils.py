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

import os
import stat
from textwrap import dedent
from unittest import TestCase
from unittest.mock import Mock, patch

from tests.utils import build_terraform_command, TerraformExecutor, TerraformLogLevel


class TestBuildTerraformCommand(TestCase):
    def test_happy_path(self) -> None:
        expected_terraform_command = """\
            #!/bin/bash
            set -ex
            TF_WORKSPACE=test terraform -chdir=/some/module/path init -upgrade -input=false
            TF_WORKSPACE=test TF_LOG=INFO terraform -chdir=/some/module/path apply --auto-approve -var-file=test.tfvars
        """
        self.assertEqual(
            dedent(expected_terraform_command),
            build_terraform_command(
                terraform_workspace="test",
                terraform_vars_file="test.tfvars",
                terraform_vars={},
                module_path="/some/module/path",
                log_level=TerraformLogLevel.INFO,
                cmd="apply",
            ),
        )

    def test_single_terraform_vars(self) -> None:
        expected_terraform_command = """\
            #!/bin/bash
            set -ex
            TF_WORKSPACE=test terraform -chdir=/some/module/path init -upgrade -input=false
            TF_WORKSPACE=test TF_LOG=INFO terraform -chdir=/some/module/path apply --auto-approve -var-file=test.tfvars -var='hello=world'
        """
        self.assertEqual(
            dedent(expected_terraform_command),
            build_terraform_command(
                terraform_workspace="test",
                terraform_vars_file="test.tfvars",
                terraform_vars={"hello": "world"},
                module_path="/some/module/path",
                log_level=TerraformLogLevel.INFO,
                cmd="apply",
            ),
        )

    def test_multiple_terraform_vars(self) -> None:
        expected_terraform_command = """\
            #!/bin/bash
            set -ex
            TF_WORKSPACE=test terraform -chdir=/some/module/path init -upgrade -input=false
            TF_WORKSPACE=test TF_LOG=INFO terraform -chdir=/some/module/path apply --auto-approve -var-file=test.tfvars -var='hello=world' -var='wee=womp'
        """
        self.assertEqual(
            dedent(expected_terraform_command),
            build_terraform_command(
                terraform_workspace="test",
                terraform_vars_file="test.tfvars",
                terraform_vars={"hello": "world", "wee": "womp"},
                module_path="/some/module/path",
                log_level=TerraformLogLevel.INFO,
                cmd="apply",
            ),
        )


class TestTerraformDeploy(TestCase):
    @patch("tests.utils.os.chmod")
    @patch("tests.utils.subprocess")
    def test_happy_path(self, mock_subprocess: Mock, mock_os_chmod: Mock) -> None:
        executor = TerraformExecutor(
            terraform_workspace="test",
            terraform_vars_file="test.tfvars",
            terraform_vars={},
            module_path="/some/module/path",
            log_level=TerraformLogLevel.INFO,
        )
        executor.deploy()
        mock_subprocess.run.assert_called_once()
        mock_os_chmod.assert_called_once()

        # Ensure the script written to disk is executable
        _, perm_bits = mock_os_chmod.mock_calls[0][1]
        filemode: str = stat.filemode(perm_bits)
        self.assertEqual("-rwx------", filemode)
