# OpenAI

We use OpenAI's API to generate images for use during streams.

## OpenAI account setup

1. Register an OpenAI account.
2. Browse to the [API Keys](https://platform.openai.com/account/api-keys) section of
   your account.
3. Click **Create a new secret key**, then enter `Golden VCR Image Generation` and
   click **Create secret key**.
4. Copy the resulting key value and add it to `secret.auto.tfvars` as
   `openai_api_key`.
