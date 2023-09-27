#!/usr/bin/env bash

POSTGRESQL_VERSION=16

GVCR_DATA_MOUNT=/mnt/gvcr_data
POSTGRESQL_DATA_DIR="$GVCR_DATA_MOUNT/pgdata"

if [ ! -d $GVCR_DATA_MOUNT ]; then
    echo "ERROR: $GVCR_DATA_MOUNT does not exist. Is gvcr-data volume mounted?"
    exit 1
fi

systemctl --no-pager status postgresql
if [ $? -eq 0 ]; then
    echo "PostgreSQL is already installed."
    exit
fi

echo "Installing PostgreSQL..."
set -e

echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install -y "postgresql-$POSTGRESQL_VERSION"

echo "Shutting down PostgreSQL for maintenance..."
sleep 1
systemctl stop postgresql
sleep 1

echo "Setting permissions on $POSTGRESQL_DATA_DIR..."
mkdir -p "$POSTGRESQL_DATA_DIR"
chown postgres:postgres "$POSTGRESQL_DATA_DIR"
chmod 700 "$POSTGRESQL_DATA_DIR"

echo "Checking for existing PostgreSQL data in $POSTGRESQL_DATA_DIR..."
if [ -z "$(ls -A $POSTGRESQL_DATA_DIR)" ]; then
    echo "No existing data! Copying from /var/lib/postgresql/$POSTGRESQL_VERSION/main..."
    rsync -av /var/lib/postgresql/$POSTGRESQL_VERSION/main/* "$POSTGRESQL_DATA_DIR"
else
    echo "Detected data from previous installation!"
fi

echo "Updating postgresql.conf to set data_directory to $POSTGRESQL_DATA_DIR..."
sed -i "s|^data_directory\s*=.*|data_directory = '$POSTGRESQL_DATA_DIR'|g" "/etc/postgresql/$POSTGRESQL_VERSION/main/postgresql.conf"

echo "Deleting /var/lib/postgresql/$POSTGRESQL_VERSION/main..."
rm -rf "/var/lib/postgresql/$POSTGRESQL_VERSION/main"

echo "Restarting PostgreSQL..."
systemctl start postgresql

echo "PostgreSQL is now installed."
