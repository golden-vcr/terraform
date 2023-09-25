#!/usr/bin/env bash

systemctl --no-pager status nginx
if [ $? -eq 0 ]; then
    echo "NGINX is already installed."
    exit
fi

echo "Installing NGINX..."
set -e
apt-get update
apt-get install -y nginx
echo "NGINX is now installed."
