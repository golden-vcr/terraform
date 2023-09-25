#!/usr/bin/env bash
set -e
SSH_KEY="~/.ssh/digitalocean-golden-vcr"
echo "Updating Golden VCR server..."

echo -e "\n== Resolving server IP address..."
SSH_USER="root"
SSH_ADDRESS=$(terraform output -raw server_ip_address)
SSH_DEST="$SSH_USER@$SSH_ADDRESS"
echo "SSH destination: $SSH_DEST"

if [ ! -d ./server-init/ssl ]; then
    echo -e "\n== Writing SSL certificate files locally..."
    mkdir -p ./server-init/ssl
    terraform output -raw goldenvcr_ssl_certificate > ./server-init/ssl/goldenvcr.com.crt
    terraform output -raw goldenvcr_ssl_certificate_key > ./server-init/ssl/goldenvcr.com.key
fi

echo -e "\n== Preparing .env files with config details from Terraform state..."
mkdir -p ./server-init/env
terraform output -raw postgres_init_script > ./server-init/env/init-postgres.sh.tmp
tr -d '\015' < ./server-init/env/init-postgres.sh.tmp > ./server-init/env/init-postgres.sh
rm ./server-init/env/init-postgres.sh.tmp
terraform output -raw sheets_api_env > ./server-init/env/tapes.env
terraform output -raw images_s3_env >> ./server-init/env/tapes.env
terraform output -raw twitch_api_env > ./server-init/env/showtime.env
terraform output -raw showtime_db_env >> ./server-init/env/showtime.env
echo "Wrote to: ./server-init/env"

echo -e "\n== Copying management scripts and SSL certificates to /gvcr..."
ssh -i $SSH_KEY "$SSH_DEST" "mkdir -p /gvcr"
scp -i $SSH_KEY -r ./server-init/ssl "$SSH_DEST:/gvcr/ssl"
scp -i $SSH_KEY ./server-init/install-postgres.sh "$SSH_DEST:/gvcr/install-postgres.sh"
scp -i $SSH_KEY ./server-init/env/init-postgres.sh "$SSH_DEST:/gvcr/init-postgres.sh"
scp -i $SSH_KEY ./server-init/install-nginx.sh "$SSH_DEST:/gvcr/install-nginx.sh"
scp -i $SSH_KEY ./server-init/manage.sh "$SSH_DEST:/gvcr/manage.sh"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'chmod +x /gvcr/*.sh'"

echo -e "\n== Ensuring that PostgreSQL is installed..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./install-postgres.sh'"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./init-postgres.sh'"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'rm /gvcr/init-postgres.sh'"

echo -e "\n== Ensuring that NGINX is installed..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./install-nginx.sh'"

echo -e "\n== Updating and reloading NGINX config..."
scp -i $SSH_KEY ./server-init/goldenvcr.conf "$SSH_DEST:/etc/nginx/conf.d/goldenvcr.conf"
ssh -i $SSH_KEY "$SSH_DEST" "nginx -s reload"

echo -e "\n== Running latest version of tapes API..."
scp -i $SSH_KEY ./server-init/env/tapes.env "$SSH_DEST:/gvcr/tapes.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh tapes update /gvcr/tapes.env'"

echo -e "\n== Running latest version of showtime API..."
scp -i $SSH_KEY ./server-init/env/showtime.env "$SSH_DEST:/gvcr/showtime.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh showtime update /gvcr/showtime.env'"

echo -e "\nGolden VCR server updated."
