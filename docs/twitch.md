# Twitch

We use the Twitch API in the [showtime](https://github.com/golden-vcr/showtime) API,
allowing our backend to receive event notifications from Twitch.

### Twitch API setup

There's no Terraform provider for Twitch, but we still store Twitch-related secrets in
Terraform. To set up your Twitch developer credentials initially:

1. Log into the Twitch Developer console and navigate to
   [Applications](https://dev.twitch.tv/console/apps).
2. Click **Register Your Application**, and enter the following details:
    - **Name:** Golden VCR
    - **OAuth Redirect URLs:** http://localhost:3033/auth
    - **Category:** Website Integration
3. Click **Create**, then click **Manage** next to the new **Golden VCR** entry.
4. Copy the **Client ID** value and add it to `secret.auto.tfvars` as
   `twitch_app_client_id`.
5. Click **New Secret**, then copy the value and add it to `secret.auto.tfvars` as
   `twitch_app_client_secret`.

Note that creating event subscriptions via the EventSub API is outside the purview of
the terraform repo. Once the backend is deployed and your Twitch credentials are
configured, you'll need to do some additional first-time setup to register webhooks
with Twitch. For more information on that process, see the README in the
[showtime](https://github.com/golden-vcr/showtime) repo.
