import os
import stat
from textwrap import dedent
from unittest import TestCase
from unittest.mock import Mock, patch

from tests.utils import build_terraform_command, terraform_deploy, TerraformLogLevel


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
                terraform_workspace='test',
                terraform_vars_file='test.tfvars',
                terraform_vars={},
                module_path='/some/module/path',
                log_level=TerraformLogLevel.INFO,
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
                terraform_workspace='test',
                terraform_vars_file='test.tfvars',
                terraform_vars={'hello': 'world'},
                module_path='/some/module/path',
                log_level=TerraformLogLevel.INFO,
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
                terraform_workspace='test',
                terraform_vars_file='test.tfvars',
                terraform_vars={'hello': 'world', 'wee': 'womp'},
                module_path='/some/module/path',
                log_level=TerraformLogLevel.INFO,
            ),
        )


class TestTerraformDeploy(TestCase):
    @patch('tests.utils.os.chmod')
    @patch('tests.utils.subprocess')
    def test_happy_path(self, mock_subprocess: Mock, mock_os_chmod: Mock) -> None:
        terraform_deploy(
            terraform_workspace='test',
            terraform_vars_file='test.tfvars',
            terraform_vars={},
            module_path='/some/module/path',
            log_level=TerraformLogLevel.INFO,
        )
        mock_subprocess.run.assert_called_once()
        mock_os_chmod.assert_called_once()

        # Ensure the script written to disk is executable
        _, perm_bits = mock_os_chmod.mock_calls[0][1]
        filemode: str = stat.filemode(perm_bits)
        self.assertEqual('-rwx------', filemode)
