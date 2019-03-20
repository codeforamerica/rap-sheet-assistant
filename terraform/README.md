# Deploying new infrastructure on AWS

## Install and configure Terraform

We use [Terraform](https://www.terraform.io/) to manage Rap Sheet Assistant's infrastructure. Install Terraform
with [Homebrew](https://brew.sh/): `brew install terraform`; or by [downloading the installer](https://www.terraform.io/downloads.html).

For each environment you must provide a backend that points to an [s3 terraform backend provider](https://www.terraform.io/docs/backends/types/s3.html). 
We put our backend file for our existing environments in [a LastPass secure note](https://helpdesk.lastpass.com/secure-notes/) 
named `rap-assist-backend-config-<ENV>`:
```
bucket     = "[THE NAME OF YOUR TERRAFORM STATE BUCKET]"
```

We expect each user of the system to provide their aws credentials in the `~/.aws/credentials` file under a profile 
named `rap-assist-<ENV>`.

On the command line, cd into the directory for the environment you want to deploy, and use the `terraform init` command 
to initialize terraform (replacing "staging" with the environment of your choice):
```bash
terraform init -backend-config =(lpass show --notes rap-assist-backend-config-staging)
```
(on zsh)

```bash
terraform init -backend-config <(lpass show --notes rap-assist-backend-config-staging)
```
(on bash)

## Deploying changes to the infrastructure
Simply run the following command, replacing "staging" with whatever environment you are deploying.

```bash
terraform apply -var-file <(lpass show --notes rap-assist-var-file-staging)
```

If you are using zsh instead of bash, simply replace the `<` with `=` as above.

## Troubleshooting

If the init command fails with a credential chain error, you may need to add a "default" profile in your aws credentials
file, as described in this [gitub issue](https://github.com/hashicorp/terraform/issues/5839).

