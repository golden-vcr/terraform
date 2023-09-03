resource "google_project_service" "sheets" {
  project = var.google_project_name
  service = "sheets.googleapis.com"
}

resource "google_project_service" "apikeys" {
  project = var.google_project_name
  service = "apikeys.googleapis.com"
}

resource "google_apikeys_key" "sheets" {
  project      = var.google_project_name
  name         = "sheets"
  display_name = "Sheets API access for backend services"

  restrictions {
    api_targets {
      service = "sheets.googleapis.com"
    }
  }
}

output "sheets_api_key" {
  value     = google_apikeys_key.sheets.key_string
  sensitive = true
}
