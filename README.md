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

### DigitalOcean authentication

We use DigitalOcean to run the majority of our app's backend infrastructure. To
configure access to DigitalOcean:

1. Log in to [cloud.digitalocean.com](https://cloud.digitalocean.com/) and create an
   account.
2. Under [API &rarr; Tokens](https://cloud.digitalocean.com/account/api/tokens),
   generate a new token named `terraform` with full read/write access
3. Copy the resulting token value
4. Create a file in the root of this repo called `secret.auto.tfvars`, and paste in the
   token for the value of `digitalocean_token`.
5. Under the **Spaces Keys** section of the same tokens page, generate a new key. Paste
   the key ID (the first value) into the same file as `digitalocean_spaces_key_id`, and
   paste the secret (the second value) as `digitalocean_spaces_secret`.

Your `secret.auto.tfvars` file should look like this:

```terraform
digitalocean_token = "dop_v1_123fed...cba789"
digitalocean_spaces_key_id = "AB00..99ZZ"
digitalocean_spaces_secret = "XY/z...b+ABC"
```

If successful, you should be able to run `terraform plan` without being prompted to
enter a value for `var.digitalocean_token`, and without encountering any 401 errors
that say `Unable to authenticate you`.

### DigitalOcean SSH key

terraform expects a public key to be present on your machine at
`~/.ssh/digitalocean-golden-vcr.pub`: it will add this key to your DigitalOcean
account, then add it to any droplets that it creates. This will allow you to use the
accompanying private key (`~/.ssh/digitalocean-golden-vcr`) to connect to any droplet
that's been provisioned via terraform.

To create a key:

1. Run `ssh-keygen`, and create a new RSA key at `~/.ssh/digitalocean-golden-vcr`

If successful, you should now be able to run `terraform plan` without encountering an
`Invalid value for "path" parameter: no file exists at "~/.ssh/digitalocean-golden-vcr.pub"`
error.

### Cloudflare Authentication

We use Cloudflare as a domain registrar, and we use the `cloudflare` terraform provider
to manage DNS records associated with our domain (`goldenvcr.com`). To configure
terraform with a Cloudflare API key:

1. Log in to [dash.cloudflare.com](https://dash.cloudflare.com/) as
   `goldenvcr@gmail.com` and ensure that your email address is verified and your
   account has a payment method on file.
2. Under **Domain Registration** &rarr; **Register Domains**, ensure that
   `goldenvcr.com` is registered under your account.
3. Under [Profile &rarr; API Tokens](https://dash.cloudflare.com/profile/api-tokens),
   create a token named `terraform` using the **Edit zone DNS** template, then:
    - Select `goldenvcr.com` as the specific zone to include under **Zone Resources**
    - Under **Permissions**, add the following items, all with **Edit** privileges:
        - **Zone**: **DNS** _(already included from template)_
        - **Zone**: **Zone Settings**
        - **Zone**: **SSL and Certificates**
        - **Zone**: **Dynamic Redirect**
4. Copy the new token value.
5. Add a new line to `secret.auto.tfvars`, setting the value of `cloudflare_token` to
   the string you just copied.
6. In the right sidebar of thethe domain's **Overview** page, find the **Zone ID**
   value and copy it.
7. Add a new line to `secret.auto.tfvars`, setting the value of `cloudflare_zone_id` to
   this value.

At this point, your `secret.auto.tfvars` file should look something like this:

```terraform
digitalocean_token = "dop_v1_123fed...cba789"
digitalocean_spaces_key_id = "AB00..99ZZ"
digitalocean_spaces_secret = "XY/z...b+ABC"
cloudflare_token = "vf5Zq...WbC"
cloudflare_zone_id = "abc1...9fff"
```

If successful, you should be able to run `terraform plan` and `terraform apply` without
being prompted to enter Cloudflare vars and without encountering any Cloudflare-related
errors.

### Google Cloud authentication

We use Google Cloud in order to manage access to the Sheets API. In order to use the
`google` provider in terraform, you'll need to be authenticated with Google Cloud:

1. Log in to [console.cloud.google.com](https://console.cloud.google.com/) as
   `goldenvcr@gmail.com`, and create a new project called `golden-vcr-api`
2. Install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) on your
   local machine. When the installation is finished, you should be prompted to run
   `gcloud init` to initialize the CLI.
3. When prompted to log in, select `goldenvcr@gmail.com` and authorize CLI access.

If successful, you should now be able to access the details for the `golden-vcr-api`
project:

```
> gcloud projects describe golden-vcr-api
createTime: '2023-09-03T15:53:14.909Z'
lifecycleState: ACTIVE
name: Golden VCR API
projectId: golden-vcr-api
projectNumber: '547983157914'
```

Next, you'll need to enable access via the **Google Auth Library** in order for the
`google` terraform provider to be able to access your account using the authentication
details you just configured:

4. Run `gcloud auth application-default login`, then select the same account and grant
   access.

If successful, you should be able to run `terraform plan` (after completing the
remaining setup steps detailed below) without encountering a
`google: could not find default credentials` error.

This allows basic programmatic access to your Google Cloud account via terraform.
However, terraform will still be unable to provision certain kinds of `google`
resources which require a quota project to be set. This can be resolved by setting a
quota project:

5. Run `gcloud auth application-default set-quota-project golden-vcr-api`
6. If prompted to enable the `cloudresourcemanager.googleapis.com` service for the
   project, agree and continue

If successful, you should be able to run `terraform plan` without getting
`403: Your application is authenticating by using local Application Default Credentials`
errors.

### Twitch API setup

1. Log into the Twitch Developer console and navigate to
   [Applications](https://dev.twitch.tv/console/apps).
2. Click **Register Your Application**, and enter the following details:
    - **Name:** Golden VCR
    - **OAuth Redirect URLs:** http://localhost
    - **Category:** Website Integration
3. Click **Create**, then click **Manage** next to the new **Golden VCR** entry.
4. Copy the **Client ID** value and add it to `secret.auto.tfvars` as
   `twitch_app_client_id`.
5. Click **New Secret**, then copy the value and add it to `secret.auto.tfvars` as
   `twitch_app_client_secret`.

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
