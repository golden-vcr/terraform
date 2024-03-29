#!/usr/bin/env bash
set -e
SSH_KEY="~/.ssh/digitalocean-golden-vcr"
echo "Updating RabbitMQ server..."

terraform_output() {
    terraform output -raw "$1" | tr -d '\015'
}

echo -e "\n== Resolving server IP address..."
SSH_USER="root"
SSH_ADDRESS=$(terraform output -raw rabbitmq_server_ip_address)
SSH_DEST="$SSH_USER@$SSH_ADDRESS"
echo "SSH destination: $SSH_DEST"

echo -e "\n== Copying scripts to /gvcr..."
ssh -i $SSH_KEY "$SSH_DEST" "mkdir -p /gvcr"
terraform_output rabbitmq_init_script > ./server-init/env/rmq-init.sh
scp -i $SSH_KEY ./server-init/install-rabbitmq.sh "$SSH_DEST:/gvcr/install-rabbitmq.sh"
scp -i $SSH_KEY ./server-init/env/rmq-init.sh "$SSH_DEST:/gvcr/rmq-init.sh"
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'chmod +x /gvcr/*.sh'"

echo -e "\n== Ensuring that RabbitMQ is installed..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./install-rabbitmq.sh'"

echo -e "\n== Configuring RabbitMQ via rabbitmqctl..."
ssh -i $SSH_KEY "$SSH_DEST" "sh -c 'cd /gvcr && ./rmq-init.sh'"

echo -e "\nRabbitMQ server updated."
