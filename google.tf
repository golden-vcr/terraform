variable "google_project_name" {
  type        = string
  description = "Name of the project created via the web UI at https://console.cloud.google.com"
  default     = "golden-vcr-api"
}

provider "google" {
  project               = var.google_project_name
  region                = "us-central1"
  zone                  = "us-central1-c"
  user_project_override = true
}
