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
terraform_output env_auth > ./server-init/env/auth.env
terraform_output env_ledger > ./server-init/env/ledger.env
terraform_output env_tapes > ./server-init/env/tapes.env
terraform_output env_showtime > ./server-init/env/showtime.env
terraform_output env_hooks > ./server-init/env/hooks.env
terraform_output env_chatbot > ./server-init/env/chatbot.env
terraform_output env_dispatch > ./server-init/env/dispatch.env
terraform_output env_broadcasts > ./server-init/env/broadcasts.env
terraform_output env_dynamo > ./server-init/env/dynamo.env
terraform_output env_alerts > ./server-init/env/alerts.env
terraform_output env_remix > ./server-init/env/remix.env
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

echo -e "\n== Copying temporary data migration scripts..."
ssh -i $SSH_KEY "$SSH_DEST" "mkdir -p /gvcr/migrate"
scp -i $SSH_KEY ./server-init/migrate/* "$SSH_DEST:/gvcr/migrate"

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

echo -e "\n== Running latest version of auth service..."
scp -i $SSH_KEY ./server-init/env/auth.env "$SSH_DEST:/gvcr/auth.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh auth update /gvcr/auth.env'"

echo -e "\n== Running latest version of ledger service..."
scp -i $SSH_KEY ./server-init/env/ledger.env "$SSH_DEST:/gvcr/ledger.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh ledger update /gvcr/ledger.env'"

echo -e "\n== Running latest version of tapes service..."
scp -i $SSH_KEY ./server-init/env/tapes.env "$SSH_DEST:/gvcr/tapes.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh tapes update /gvcr/tapes.env'"

echo -e "\n== Running latest version of showtime service..."
scp -i $SSH_KEY ./server-init/env/showtime.env "$SSH_DEST:/gvcr/showtime.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh showtime update /gvcr/showtime.env'"

echo -e "\n== Running latest version of hooks service..."
scp -i $SSH_KEY ./server-init/env/hooks.env "$SSH_DEST:/gvcr/hooks.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh hooks update /gvcr/hooks.env'"

echo -e "\n== Running latest version of chatbot service..."
scp -i $SSH_KEY ./server-init/env/chatbot.env "$SSH_DEST:/gvcr/chatbot.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh chatbot update /gvcr/chatbot.env'"

echo -e "\n== Running latest version of dispatch service..."
scp -i $SSH_KEY ./server-init/env/dispatch.env "$SSH_DEST:/gvcr/dispatch.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh dispatch update /gvcr/dispatch.env'"

echo -e "\n== Running latest version of broadcasts service..."
scp -i $SSH_KEY ./server-init/env/broadcasts.env "$SSH_DEST:/gvcr/broadcasts.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh broadcasts update /gvcr/broadcasts.env'"

echo -e "\n== Running latest version of dynamo service..."
scp -i $SSH_KEY ./server-init/env/dynamo.env "$SSH_DEST:/gvcr/dynamo.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh dynamo update /gvcr/dynamo.env'"

echo -e "\n== Running latest version of alerts service..."
scp -i $SSH_KEY ./server-init/env/alerts.env "$SSH_DEST:/gvcr/alerts.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh alerts update /gvcr/alerts.env'"

echo -e "\n== Running latest version of remix service..."
scp -i $SSH_KEY ./server-init/env/remix.env "$SSH_DEST:/gvcr/remix.env"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./manage.sh remix update /gvcr/remix.env'"

echo -e "\n== Preparing crontab file to configure scheduled jobs..."
scp -i $SSH_KEY ./server-init/crontab "$SSH_DEST:/gvcr/crontab.tmp"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && tr -d '\''\r'\'' <crontab.tmp >crontab && rm crontab.tmp && crontab ./crontab'"

echo -e "\nGolden VCR server updated."
