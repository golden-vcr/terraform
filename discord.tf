variable discord_ghosts_webhook_url {
  description = "URL for a webhook that posts to #ghosts, configured in Discord Server settings under the Integrations section; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable discord_friends_webhook_url {
  description = "URL for a webhook that posts friend images, configured in Discord Server settings under the Integrations section; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable discord_notifications_webhook_url {
  description = "URL for a webhook that posts to #watch, configured in Discord Server settings under the Integrations section; should be set in secret.auto.tfvars"
  sensitive   = true
}
