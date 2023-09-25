#!/usr/bin/env bash

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
apt-get install -y postgresql-16
echo "PostgreSQL is now installed."
