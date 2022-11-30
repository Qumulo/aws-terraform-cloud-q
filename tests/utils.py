from enum import Enum
import json
import os
import stat
import subprocess
from tempfile import NamedTemporaryFile
from typing import Any, Dict


class TerraformLogLevel(Enum):
    TRACE = 'TRACE'
    DEBUG = 'DEBUG'
    INFO = 'INFO'
    WARN = 'WARN'
    ERROR = 'ERROR'


def build_setup_commands(terraform_workspace: str, module_path: str) -> str:
    command = '#!/bin/bash\nset -ex\n'
    command += (
        f'TF_WORKSPACE={terraform_workspace} terraform -chdir={module_path} init -upgrade'
        ' -input=false\n'
    )
    return command


def build_terraform_command(
    terraform_workspace: str,
    terraform_vars_file: str,
    terraform_vars: dict[str, str],
    module_path: str,
    log_level: TerraformLogLevel,
    cmd: str,
) -> str:
    terraform_command = build_setup_commands(
        terraform_workspace=terraform_workspace, module_path=module_path
    )
    terraform_command += (
        f'TF_WORKSPACE={terraform_workspace} TF_LOG={log_level.name} terraform'
        f' -chdir={module_path}'
        f' {cmd} --auto-approve'
        f' -var-file={terraform_vars_file}'
    )

    # Add extra terraform variables to the command
    for key, value in terraform_vars.items():
        terraform_command += f" -var='{key}={value}'"

    terraform_command += '\n'
    return terraform_command


class TerraformExecutor(object):
    def __init__(
        self,
        terraform_workspace: str,
        terraform_vars_file: str,
        terraform_vars: Dict[str, str],
        module_path: str,
        log_level: TerraformLogLevel,
    ):
        self.terraform_workspace = terraform_workspace
        self.terraform_vars_file = terraform_vars_file
        self.terraform_vars = terraform_vars
        self.module_path = module_path
        self.log_level = log_level

    def deploy(self) -> subprocess.CompletedProcess:
        """Deploy a terraform module given a specified module path."""
        script_file = NamedTemporaryFile()
        try:
            with open(script_file.name, mode='w') as f:
                f.write(
                    build_terraform_command(
                        terraform_workspace=self.terraform_workspace,
                        terraform_vars_file=self.terraform_vars_file,
                        terraform_vars=self.terraform_vars,
                        module_path=self.module_path,
                        log_level=self.log_level,
                        cmd='apply',
                    )
                )
            # Make the script executable
            st = os.stat(script_file.name)
            os.chmod(script_file.name, st.st_mode | stat.S_IEXEC)

            # Execute the terraform script
            return subprocess.run(['/bin/sh', script_file.name])
        finally:
            script_file.close()

    def destroy(self) -> subprocess.CompletedProcess:
        """Destroy a terraform module given a specified module path."""
        script_file = NamedTemporaryFile()
        try:
            with open(script_file.name, mode='w') as f:
                f.write(
                    build_terraform_command(
                        terraform_workspace=self.terraform_workspace,
                        terraform_vars_file=self.terraform_vars_file,
                        terraform_vars=self.terraform_vars,
                        module_path=self.module_path,
                        log_level=self.log_level,
                        cmd='apply -destroy',
                    )
                )
            # Make the script executable
            st = os.stat(script_file.name)
            os.chmod(script_file.name, st.st_mode | stat.S_IEXEC)

            # Execute the terraform script
            return subprocess.run(['/bin/sh', script_file.name])
        finally:
            script_file.close()
