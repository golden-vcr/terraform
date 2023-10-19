variable openai_api_key {
  description = "API key used to generate images via OpenAI, obtained from https://platform.openai.com/account/api-keys; should be set in secret.auto.tfvars"
  sensitive   = true
}

output "openai_api_env" {
  value     = <<EOT
OPENAI_API_KEY=${var.openai_api_key}
EOT
  sensitive = true
}
