# terraform

The **terraform** repo declares the resources that are required to provision our app's
required infrastructure. Currently, the Golden VCR webapp is run on DigitalOcean.

## Prerequisites

Install the latest version of terraform and add it to your PATH:

- https://developer.hashicorp.com/terraform/downloads

You should then be able to run:

```
> terraform -version
Terraform v1.5.6
on windows_amd64
```

## One-time setup

First, you'll want to ensure that you have an SSH key for use with DigitalOcean. This
isn't required to apply terraform configuration: instead, it's added to droplets that
are created via terraform, so that you can SSH into them from your local machine.

To create a key, run `ssh-keygen` and create a new RSA key at
`~/.ssh/digitalocean-golden-vcr`. The terraform configuration in
`digitalocean.account.tf` will pick up on this file and add it to your DigitalOcean
account automatically.

Next, you'll want to ensure that you're logged into a DigitalOcean account, and then
you'll need to configure a DigitalOcean API token:

1. Visit https://cloud.digitalocean.com/account/api/tokens
2. Generate a new token named `terraform` with full read/write access
3. Copy the token value
4. Create a file in the root of this repo called `secret.auto.tfvars`, and paste in the
   token for the value of `digitalocean_token`

Your `secret.auto.tfvars` file should look like this:

```terraform
digitalocean_token = "dop_v1_123fed..."
```

## Running terraform

Before you can provision any resources, you'll need to initialize terraform state:

- `terraform init`

Once you've run terraform init, you should have a `.terraform` directory that contains
unversioned build state. You can refresh this state as needed by re-running
`terraform init`. If you need to entirely clobber your local state and start fresh, you
can do so by running `rm -rf .terraform/ && terraform init`.

Once the project is initialized, you can preview the results of your local config
changes by running:

- `terraform plan -out=plan`
- `terraform apply plan`

If you want to take the project offline in order to stop paying for the resources that
have been provisioned via terraform, you can destroy all resources with:

- `terraform destroy`

## Testing

Once you've run `terraform apply` for the first time, you should have a new
DigitalOcean droplet called `api`, running in a project called `golden-vcr`, configured
to allow remote access via your `digitalcean-golden-vcr` SSH key.

Once this droplet is running, you can get its public IP address by running
`terraform output api_ip_address`. You can then connect to the droplet over SSH as
`root`, e.g.:

- `ssh -i ~/.ssh/digitalocean-golden-vcr root@165.227.112.138`

Or, as a one-liner in bash:

- `ssh -i ~/.ssh/digitalocean-golden-vcr "root@$(terraform output -raw api_ip_address)"`

Accept the fingerprint of the host key if prompted, and you should be dropped into a
shell on the droplet. If that works, then you've configured terraform correctly.
