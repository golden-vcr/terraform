# Cloudflare

We use Cloudflare as a domain registrar, and we use the `cloudflare` terraform provider
to manage DNS records associated with our domain (`goldenvcr.com`).

### Cloudflare Authentication

To configure terraform with a Cloudflare API key:

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
