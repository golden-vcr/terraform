# Discord

This guide assumes that a Discord server is already created and configured. Roughly
speaking, the server is configured like so:

- **Name:** Golden VCR
- **Roles:** Broadcaster, Moderator, Subscriber
- **Channels:**
    - `#general`: public, for general discussion, announcement, etc.
    - `#watch`: public, for discussion and free-form chatter during streams (or
      commentary on VODs)
    - `#ghosts`: public, for an automatic feed of ghost images submitted during streams
      (and discussion thereof)

To set up a webhook that will allow us to automatically post ghost alerts in `#ghosts`:

1. Under **Server Settings**, browse to the **Integrations** section, then click
   **Create Webhook**.
2. Name the new webhook **Haunted VCR**, and configure it to post in the `#ghosts`
   channel.
3. Click **Copy Webhook URL**, then paste that value in `secret.auto.tfvars` as
   `discord_ghosts_webhook_url`.

Repeat the same steps to create a Webhook for posting friend images, then paste the
resulting URL into `secret.auto.tfvars` as `discord_friends_webhook_url`.

We also need a webhook that will let us post notifications in `#watch`, for when the
stream goes live etc.:

1. Under **Server Settings**, browse to the **Integrations** section, then click
   **Create Webhook**.
2. Name the new webhook **Golden VCR Notifications**, and configure it to post in the
   `#watch` channel.
3. Click **Copy Webhook URL**, then paste that value in `secret.auto.tfvars` as
   `discord_notifications_webhook_url`.
