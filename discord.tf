variable discord_ghosts_webhook_url {
  description = "URL for a webhook that posts to #ghosts, configured in Discord Server settings under the Integrations section; should be set in secret.auto.tfvars"
  sensitive   = true
}
