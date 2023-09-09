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
on linux_amd64
```

Some scripts require [jq](https://jqlang.github.io/jq/): install it, and then you
should be able to run:

```
jq --version
jq-1.5-1-a5b5cbe
```

## One-time setup

The Golden VCR app depends on a number of third-party providers. For details on how we
use each of them, along with instructions on initial setup and configuration, see the
respective documentation:

- [DigitalOcean](./docs/digitalocean.md)
- [Cloudflare](./docs/cloudflare.md)
- [Google](./docs/google.md)
- [Twitch](./docs/twitch.md)

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

### Verifying access to Google Sheets API

The [**Golden VCR Inventory** spreadsheet](https://docs.google.com/spreadsheets/d/1cR9Lbw9_VGQcEn8eGD2b5MwGRGzKugKZ9PVFkrqmA7k/edit#gid=0)
has an ID of `1cR9Lbw9_VGQcEn8eGD2b5MwGRGzKugKZ9PVFkrqmA7k`. Once you've run
`terraform apply`, the `golden-vcr` project should include a simple API key that
permits access to the Google Sheets API.

You can get the value of this API key by running `terraform output sheets_api_key`, and
you can supply this key in HTTP requests to verify that the Sheets API is working.

For example, to get the details of the inventory spreadsheet, you can run (in bash):

- `curl -H "X-goog-api-key: $(terraform output -raw sheets_api_key)" https://sheets.googleapis.com/v4/spreadsheets/1cR9Lbw9_VGQcEn8eGD2b5MwGRGzKugKZ9PVFkrqmA7k`

If you get a valid JSON response with no errors, then Google Sheets API access is
working as configured.

### Verifying SSH access to DigitalOcean droplet

Once you've run `terraform apply` for the first time, you should have a new
DigitalOcean droplet called `api`, running in a project called `golden-vcr`, configured
to allow remote access via your `digitalcean-golden-vcr` SSH key.

Once this droplet is running, you can get its public IP address by running
`terraform output server_ip_address`. You can then connect to the droplet over SSH as
`root`, e.g.:

- `ssh -i ~/.ssh/digitalocean-golden-vcr root@165.227.112.138`

Or, as a one-liner in bash:

- `ssh -i ~/.ssh/digitalocean-golden-vcr "root@$(terraform output -raw server_ip_address)"`

Accept the fingerprint of the host key if prompted, and you should be dropped into a
shell on the droplet. If that works, then you've configured terraform correctly.

### Verifying Cloudflare

Once Cloudflare has been configured and DNS records have propagated, you should be able
to resolve the IP address of the API droplet by running `nslookup goldenvcr.com`.

## Initializing the server

Once all resources are applied, you can run `./init-server.sh` to deploy the
application.

If successful, you should be able to visit https://goldenvcr.com and load a page, with
a trusted TLS certificate from Cloudflare. You should also be able to make requests
against the API, e.g. `curl https://goldenvcr.com/api/tapes`.
