# DigitalOcean

We use DigitalOcean to run the majority of our app's backend infrastructure.

### DigitalOcean authentication

To configure access to DigitalOcean:

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
