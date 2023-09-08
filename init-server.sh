#!/usr/bin/env bash
set -e
SSH_KEY="~/.ssh/digitalocean-golden-vcr"
FORCE="0"

echo "Resolving server IP address..."
SSH_USER="root"
SSH_ADDRESS=$(terraform output -raw server_ip_address)
SSH_DEST="$SSH_USER@$SSH_ADDRESS"

if [ "$1" == "nginx" ]; then
    echo "[SCP] Copying updated NGINX config..."
    scp -i $SSH_KEY ./server-init/goldenvcr.conf "$SSH_DEST:/etc/nginx/conf.d/goldenvcr.conf"
    echo "[SSH] Reloading NGINX config..."
    ssh -i $SSH_KEY "$SSH_DEST" "nginx -s reload"
    echo "NGINX config synced."
    exit 0
fi

if [ "$1" == "-f" ] || [ "$1" == "--force" ]; then
    rm -rf ./server-init/ssl
fi

if [ ! -d ./server-init/ssl ]; then
    echo "Writing SSL certificate files locally..."
    mkdir -p ./server-init/ssl
    terraform output -raw goldenvcr_ssl_certificate > ./server-init/ssl/goldenvcr.com.crt
    terraform output -raw goldenvcr_ssl_certificate_key > ./server-init/ssl/goldenvcr.com.key
fi

mkdir -p ./server-init/env
terraform output -raw sheets_api_env > ./server-init/env/tapes.env
terraform output -raw images_s3_env >> ./server-init/env/tapes.env
terraform output -raw twitch_api_env >> ./server-init/env/showtime.env

echo "[SSH] Installing NGINX..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'apt-get update && apt-get install -y nginx'"

echo "[SSH] Terminating existing API processes..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c '[ ! -f /gvcr/manage.sh ] || /gvcr/manage.sh tapes down'"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c '[ ! -f /gvcr/manage.sh ] || /gvcr/manage.sh showtime down'"

echo "[SSH] Initializing gvcr root dir..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'rm -rf /gvcr && mkdir -p /gvcr'"

echo "[SCP] Copying SSL certificate files, NGINX config, and management scripts..."
scp -i $SSH_KEY -r ./server-init/ssl "$SSH_DEST:/gvcr/ssl"
scp -i $SSH_KEY ./server-init/manage.sh "$SSH_DEST:/gvcr/manage.sh"
ssh -i $SSH_KEY "$SSH_DEST" "chmod +x /gvcr/manage.sh"
scp -i $SSH_KEY ./server-init/goldenvcr.conf "$SSH_DEST:/etc/nginx/conf.d/goldenvcr.conf"

echo "[SSH] Reloading NGINX config..."
ssh -i $SSH_KEY "$SSH_DEST" "nginx -s reload"

echo "[SSH+SCP] Installing and configuring tapes API..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c '\
    cd /gvcr \
    && ./manage.sh tapes install \
    && mkdir -p ./tapes/bin'"
scp -i $SSH_KEY ./server-init/env/tapes.env "$SSH_DEST:/gvcr/tapes/bin/.env"

echo "[SSH+SCP] Installing and configuring showtime API..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c '\
    cd /gvcr \
    && ./manage.sh showtime install \
    && mkdir -p ./showtime/bin'"
scp -i $SSH_KEY ./server-init/env/showtime.env "$SSH_DEST:/gvcr/showtime/bin/.env"

echo "[SSH] Starting new API processes..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh tapes up'"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh showtime up'"
