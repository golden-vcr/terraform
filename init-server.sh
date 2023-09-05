#!/usr/bin/env bash
set -e
SSH_KEY="~/.ssh/digitalocean-golden-vcr"
FORCE="0"

echo "Resolving server IP address..."
SSH_USER="root"
SSH_ADDRESS=$(terraform output -raw server_ip_address)
SSH_DEST="$SSH_USER@$SSH_ADDRESS"

if [ "$1" == "-f" ] || [ "$1" == "--force" ]; then
    rm -rf ./server-init/ssl
fi

if [ ! -d ./server-init/ssl ]; then
    echo "Writing SSL certificate files locally..."
    mkdir -p ./server-init/ssl
    terraform output -raw goldenvcr_ssl_certificate > ./server-init/ssl/goldenvcr.com.crt
    terraform output -raw goldenvcr_ssl_certificate_key > ./server-init/ssl/goldenvcr.com.key
fi

echo "[SSH] Terminating tapes API..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c '[ -f /gvcr/manage-tapes.sh ] && /gvcr/manage-tapes.sh down'"

echo "[SSH] Installing NGINX..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'apt-get update && apt-get install -y nginx'"

echo "[SSH] Initializing gvcr root dir..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'rm -rf /gvcr && mkdir -p /gvcr'"

echo "[SCP] Copying SSL certificate files, NGINX config, and management scripts..."
scp -i $SSH_KEY -r ./server-init/ssl "$SSH_DEST:/gvcr/ssl"
scp -i $SSH_KEY ./server-init/manage-tapes.sh "$SSH_DEST:/gvcr/manage-tapes.sh"
scp -i $SSH_KEY ./server-init/goldenvcr.conf "$SSH_DEST:/etc/nginx/conf.d/goldenvcr.conf"

echo "[SSH] Reloading NGINX config..."
ssh -i $SSH_KEY "$SSH_DEST" "nginx -s reload"

echo "[SSH] Installing, configuring, and starting tapes API..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c '\
    cd /gvcr \
    && chmod +x ./manage-tapes.sh \
    && ./manage-tapes.sh install \
    && mkdir -p ./tapes/bin \
    && echo \"SHEETS_API_KEY=$(terraform output -raw sheets_api_key)\nSPREADSHEET_ID=1cR9Lbw9_VGQcEn8eGD2b5MwGRGzKugKZ9PVFkrqmA7k\" > ./tapes/bin/.env\
    && ./manage-tapes.sh up'"
