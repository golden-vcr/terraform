variable postgres_database_name {
  description = "Name of the database created in PostgreSQL to contain Golden VCR's persistent data"
  default     = "gvcr"
}

variable postgres_showtime_schema_name {
  description = "Name of the schema that contains the data owned by the showtime API"
  default     = "showtime"
}

variable postgres_showtime_user_name {
  description = "Name of the PostgreSQL user/role that can access the showtime schema"
  default     = "showtime"
}

resource "random_password" "postgres_showtime_password" {
  keepers = {
    schema   = var.postgres_showtime_schema_name
    username = var.postgres_showtime_user_name
    version  = 1
  }
  length = 32
}

output "postgres_init_script" {
  value     = <<EOT
#!/usr/bin/env bash
set -e

echo "Checking for existing database named '${var.postgres_database_name}'..."
HAS_DATABASE=$(sudo -u postgres psql -qtAX -c "SELECT COUNT(*) FROM pg_database WHERE datname = '${var.postgres_database_name}'")
if [ $HAS_DATABASE -eq 0 ]; then
  echo "Creating new database..."
  sudo -u postgres psql -qtAX -c "CREATE DATABASE ${var.postgres_database_name}"
fi

echo "Initializing database user '${var.postgres_showtime_user_name}' with access to schema '${var.postgres_showtime_schema_name}'..."
HAS_SHOWTIME_USER=$(sudo -u postgres psql -qtAX -c "SELECT COUNT(*) FROM pg_catalog.pg_roles WHERE rolname = '${var.postgres_showtime_user_name}'")
if [ $HAS_SHOWTIME_USER -eq 0 ]; then
  echo "Creating new database user..."
  sudo -u postgres psql -qtAX -c "CREATE ROLE ${var.postgres_showtime_user_name} WITH LOGIN PASSWORD '${random_password.postgres_showtime_password.result}'"
fi
sudo -u postgres psql -d ${var.postgres_database_name} -qtAX -c "CREATE SCHEMA IF NOT EXISTS ${var.postgres_showtime_schema_name} AUTHORIZATION ${var.postgres_showtime_user_name}"

echo "Database initialized."
EOT
  sensitive = true
}

output "showtime_db_env" {
  value     = <<EOT
PGHOST=127.0.0.1
PGDATABASE=${var.postgres_database_name}
PGUSER=${var.postgres_showtime_user_name}
PGPASSWORD=${random_password.postgres_showtime_password.result}
EOT
  sensitive = true
}
