resource "cloudflare_ruleset" "redirects" {
  zone_id     = var.cloudflare_zone_id
  name        = "redirects"
  description = "Ruleset for Cloudfront redirects"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    enabled     = true
    description = "Redirect from www subdomain to root"
    expression  = "(http.host eq \"www.goldenvcr.com\")"
    action      = "redirect"
    
    action_parameters {
      from_value {
        status_code = 301
        preserve_query_string = true
        target_url {
          expression = "concat(\"https://goldenvcr.com\", http.request.uri.path)"
        }
      }
    }
  }
}
