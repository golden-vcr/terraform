# Twitch

We use the Twitch API in the [showtime](https://github.com/golden-vcr/showtime) API,
allowing our backend to receive event notifications from Twitch.

## Twitch API setup

There's no Terraform provider for Twitch, but we still store Twitch-related secrets in
Terraform. To set up your Twitch developer credentials initially:

1. Log into the Twitch Developer console and navigate to
   [Applications](https://dev.twitch.tv/console/apps).
2. Click **Register Your Application**, and enter the following details:
    - **Name:** Golden VCR
    - **OAuth Redirect URLs:**
      - `https://goldenvcr.com/auth`
      - `http://localhost:5173/auth`
      - `http://localhost:3033/auth`
    - **Category:** Website Integration
3. Click **Create**, then click **Manage** next to the new **Golden VCR** entry.
4. Copy the **Client ID** value and add it to `secret.auto.tfvars` as
   `twitch_app_client_id`.
5. Click **New Secret**, then copy the value and add it to `secret.auto.tfvars` as
   `twitch_app_client_secret`.

We also need to manually manage a Twitch Extension. To create it initially:

1. Browse to the [Extensions](https://dev.twitch.tv/console/extensions) page in the
   Developer console.
2. Click **Create Extension**, and enter `Golden VCR Interactive Overlay` as the
   extension name.
3. On the next page, copy the **Twitch API Client ID** value and add it to
   `secret.auto.tfvars` as `twitch_extension_client_id`.
4. Choose the **Video (Full screen)** extension type, scroll down to the bottom of the
   page, and click **Create Extension Version**.
5. Once the extension version has been created, in the **Asset Hosting** tab within its
   settings page, change **Testing Base URI** to `https://localhost:5180/`.

Note that creating event subscriptions via the EventSub API is outside the purview of
the terraform repo. Once the backend is deployed and your Twitch credentials are
configured, you'll need to do some additional first-time setup to register webhooks
with Twitch. For more information on that process, see the README in the
[showtime](https://github.com/golden-vcr/showtime) repo.

For more information on building and deploying extensions, see the
[extensions](https://github.com/golden-vcr/extensions) repo.
