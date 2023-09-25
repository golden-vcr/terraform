resource "random_password" "postgres_tapes_password" {
  keepers = {
    version  = 1
  }
  length = 32
}

resource "random_password" "postgres_showtime_password" {
  keepers = {
    version  = 1
  }
  length = 32
}

output "tapes_db_env" {
  value     = <<EOT
PGHOST=127.0.0.1
PGPORT=5432
PGDATABASE=tapes
PGUSER=tapes
PGPASSWORD=${random_password.postgres_tapes_password.result}
EOT
  sensitive = true
}

output "showtime_db_env" {
  value     = <<EOT
PGHOST=127.0.0.1
PGPORT=5432
PGDATABASE=showtime
PGUSER=showtime
PGPASSWORD=${random_password.postgres_showtime_password.result}
EOT
  sensitive = true
}

output "postgres_init_script" {
  value     = <<EOT
#!/usr/bin/env bash
set -e

init_db() {
  DATABASE_NAME="$1"
  SCHEMA_NAME="$1"
  USER_NAME="$1"
  PASSWORD="$2"

  echo "Checking for existing database named $DATABASE_NAME..."
  HAS_DATABASE=$(sudo -u postgres psql -qtAX -c "SELECT COUNT(*) FROM pg_database WHERE datname = '$DATABASE_NAME'")
  if [ $HAS_DATABASE -eq 0 ]; then
    echo "Creating new database..."
    sudo -u postgres psql -qtAX -c "CREATE DATABASE $DATABASE_NAME"
  fi

  echo "Initializing database user '$USER_NAME' with access to schema '$SCHEMA_NAME'..."
  HAS_USER=$(sudo -u postgres psql -qtAX -c "SELECT COUNT(*) FROM pg_catalog.pg_roles WHERE rolname = '$USER_NAME'")
  if [ $HAS_USER -eq 0 ]; then
    echo "Creating new database user..."
    sudo -u postgres psql -qtAX -c "CREATE ROLE $USER_NAME WITH LOGIN PASSWORD '$PASSWORD'"
  fi
  sudo -u postgres psql -d $DATABASE_NAME -qtAX -c "CREATE SCHEMA IF NOT EXISTS $SCHEMA_NAME AUTHORIZATION $USER_NAME"
}

init_db 'tapes' '${random_password.postgres_tapes_password.result}'
init_db 'showtime' '${random_password.postgres_showtime_password.result}'
echo "Database initialized."
EOT
  sensitive = true
}
