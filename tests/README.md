[![Qumulo Logo](https://qumulo.com/wp-content/uploads/2021/06/CloudQ-Logo_OnLight.png)](http://qumulo.com)

# aws-terraform-cloud-q ![Test Workflow Status](https://github.com/Qumulo/aws-terraform-cloud-q/actions/workflows/tests.yaml/badge.svg)

## Running Tests

### Install Dependencies

```
virtualenv -p python3 venv
. venv/bin/activate
pip3 install -r requirements.txt
```

### Setup AWS access key

- Login to your AWS account
- Navigate to IAM User console
- Follow [this](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) AWS document to setup a user access key to use in the next section

### Run tests

```
AWS_ACCESS_KEY_ID=<insert key here> AWS_SECRET_ACCESS_KEY=<insert key here> python -m pytest tests/ -s
```
