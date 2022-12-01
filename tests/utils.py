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

    def _deploy_terraform(self, command: str) -> subprocess.CompletedProcess:
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
                        cmd=command,
                    )
                )
            # Make the script executable
            st = os.stat(script_file.name)
            os.chmod(script_file.name, st.st_mode | stat.S_IEXEC)

            # Execute the terraform script
            return subprocess.run(['/bin/sh', script_file.name])
        finally:
            script_file.close()

    def deploy(self) -> subprocess.CompletedProcess:
        return self._deploy_terraform(command='apply')

    def destroy(self) -> subprocess.CompletedProcess:
        return self._deploy_terraform(command='apply -destroy')

    def output(self) -> Dict[str, Any]:
        env_copy = os.environ.copy()
        env_copy.update({'TF_WORKSPACE': self.terraform_workspace})
        process_output = (
            subprocess.check_output(
                ['terraform', 'output', '-json'],
                cwd=self.module_path,
                env=env_copy,
            )
            .decode()
            .strip()
        )
        return {k: v['value'] for k, v in json.loads(process_output).items()}
