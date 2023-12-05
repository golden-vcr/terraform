#!/usr/bin/env bash
set -e
SSH_KEY="~/.ssh/digitalocean-golden-vcr"
echo "Updating Golden VCR server..."

terraform_output() {
    terraform output -raw "$1" | tr -d '\015'
}

echo -e "\n== Resolving server IP address..."
SSH_USER="root"
SSH_ADDRESS=$(terraform output -raw server_ip_address)
SSH_DEST="$SSH_USER@$SSH_ADDRESS"
echo "SSH destination: $SSH_DEST"

echo -e "\n== Writing SSL certificate files locally..."
mkdir -p ./server-init/ssl
terraform_output goldenvcr_ssl_certificate > ./server-init/ssl/goldenvcr.com.crt
terraform_output goldenvcr_ssl_certificate_key > ./server-init/ssl/goldenvcr.com.key
echo "Wrote to: ./server-init/ssl"

echo -e "\n== Preparing .env files with config details from Terraform state..."
mkdir -p ./server-init/env
terraform_output postgres_init_script > ./server-init/env/db-init.sh
# auth
terraform_output twitch_api_env > ./server-init/env/auth.env
terraform_output auth_db_env >> ./server-init/env/auth.env
# ledger
terraform_output twitch_api_env > ./server-init/env/ledger.env
terraform_output ledger_db_env >> ./server-init/env/ledger.env
# tapes
terraform_output sheets_api_env > ./server-init/env/tapes.env
terraform_output twitch_api_env >> ./server-init/env/tapes.env
terraform_output images_s3_env >> ./server-init/env/tapes.env
terraform_output tapes_db_env >> ./server-init/env/tapes.env
# showtime
terraform_output twitch_api_env > ./server-init/env/showtime.env
terraform_output openai_api_env >> ./server-init/env/showtime.env
terraform_output user_images_s3_env >> ./server-init/env/showtime.env
terraform_output showtime_db_env >> ./server-init/env/showtime.env

echo "Wrote to: ./server-init/env"

echo -e "\n== Copying management scripts and SSL certificates to /gvcr..."
ssh -i $SSH_KEY "$SSH_DEST" "mkdir -p /gvcr/ssl"
scp -i $SSH_KEY ./server-init/ssl/* "$SSH_DEST:/gvcr/ssl"
scp -i $SSH_KEY ./server-init/mount-volume.sh "$SSH_DEST:/gvcr/mount-volume.sh"
scp -i $SSH_KEY ./server-init/install-go.sh "$SSH_DEST:/gvcr/install-go.sh"
scp -i $SSH_KEY ./server-init/install-postgres.sh "$SSH_DEST:/gvcr/install-postgres.sh"
scp -i $SSH_KEY ./server-init/env/db-init.sh "$SSH_DEST:/gvcr/db-init.sh"
scp -i $SSH_KEY ./server-init/db-dump.sh "$SSH_DEST:/gvcr/db-dump.sh"
scp -i $SSH_KEY ./server-init/install-nginx.sh "$SSH_DEST:/gvcr/install-nginx.sh"
scp -i $SSH_KEY ./server-init/manage.sh "$SSH_DEST:/gvcr/manage.sh"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'chmod +x /gvcr/*.sh'"

echo -e "\n== Ensuring that volumes are mounted..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./mount-volume.sh'"

echo -e "\n== Ensuring that Go is installed..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./install-go.sh'"

echo -e "\n== Ensuring that PostgreSQL is installed..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./install-postgres.sh'"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./db-init.sh'"

echo -e "\n== Ensuring that NGINX is installed..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./install-nginx.sh'"

echo -e "\n== Updating and reloading NGINX config..."
scp -i $SSH_KEY ./server-init/goldenvcr.conf "$SSH_DEST:/etc/nginx/conf.d/goldenvcr.conf"
ssh -i $SSH_KEY "$SSH_DEST" "nginx -s reload"

echo -e "\n== Running latest version of auth API..."
scp -i $SSH_KEY ./server-init/env/auth.env "$SSH_DEST:/gvcr/auth.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh auth update /gvcr/auth.env'"

echo -e "\n== Running latest version of ledger API..."
scp -i $SSH_KEY ./server-init/env/ledger.env "$SSH_DEST:/gvcr/ledger.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh ledger update /gvcr/ledger.env'"

echo -e "\n== Running latest version of tapes API..."
scp -i $SSH_KEY ./server-init/env/tapes.env "$SSH_DEST:/gvcr/tapes.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh tapes update /gvcr/tapes.env'"

echo -e "\n== Running latest version of showtime API..."
scp -i $SSH_KEY ./server-init/env/showtime.env "$SSH_DEST:/gvcr/showtime.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh showtime update /gvcr/showtime.env'"

echo -e "\n== Preparing crontab file to configure scheduled jobs..."
scp -i $SSH_KEY ./server-init/crontab "$SSH_DEST:/gvcr/crontab.tmp"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && tr -d '\''\r'\'' <crontab.tmp >crontab && rm crontab.tmp && crontab ./crontab'"

echo -e "\nGolden VCR server updated."
