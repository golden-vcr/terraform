# Run './local-rmq.sh env --json' to capture the RMQ env vars used to connect to the
# locally-running rabbitmq server container that's used for local development
data "external" "rabbitmq_local_env" {
    program = ["bash", "${path.module}/local-rmq.sh", "env", "--json"]
}

# Generate passwords to use for each service's RabbitMQ account in the live environment
resource "random_password" "rabbitmq_hooks_password" {
  keepers = {
    version  = 1
  }
  length = 32
}

resource "random_password" "rabbitmq_chatbot_password" {
  keepers = {
    version  = 1
  }
  length = 32
}

resource "random_password" "rabbitmq_dispatch_password" {
  keepers = {
    version  = 1
  }
  length = 32
}

# Define .env blocks for use in "env_*" output variables
locals {
    rmq_env_local = <<EOT
RMQ_HOST=${data.external.rabbitmq_local_env.result["RMQ_HOST"]}
RMQ_PORT=${data.external.rabbitmq_local_env.result["RMQ_PORT"]}
RMQ_VHOST=${data.external.rabbitmq_local_env.result["RMQ_VHOST"]}
RMQ_USER=${data.external.rabbitmq_local_env.result["RMQ_USER"]}
RMQ_PASSWORD=${data.external.rabbitmq_local_env.result["RMQ_PASSWORD"]}
EOT
    rmq_env_hooks = <<EOT
RMQ_HOST=${digitalocean_droplet.rabbitmq_server.ipv4_address_private}
RMQ_PORT=5672
RMQ_VHOST=gvcr
RMQ_USER=hooks
RMQ_PASSWORD='${random_password.rabbitmq_hooks_password.result}'
EOT
    rmq_env_chatbot = <<EOT
RMQ_HOST=${digitalocean_droplet.rabbitmq_server.ipv4_address_private}
RMQ_PORT=5672
RMQ_VHOST=gvcr
RMQ_USER=chatbot
RMQ_PASSWORD='${random_password.rabbitmq_chatbot_password.result}'
EOT
    rmq_env_dispatch = <<EOT
RMQ_HOST=${digitalocean_droplet.rabbitmq_server.ipv4_address_private}
RMQ_PORT=5672
RMQ_VHOST=gvcr
RMQ_USER=dispatch
RMQ_PASSWORD='${random_password.rabbitmq_dispatch_password.result}'
EOT
}

# Prepare a script that will initialize our self-managed RabbitMQ server with the
# required accounts etc.
output "rabbitmq_init_script" {
  value     = <<EOT
#!/usr/bin/env bash
set -e

echo "Checking existing vhosts and users..."
VHOST_NAME="gvcr"
EXISTING_VHOST_NAMES=$(rabbitmqctl list_vhosts --quiet --no-table-headers)
EXISTING_USER_NAMES=$(rabbitmqctl list_users --quiet --no-table-headers | awk '{print $1}')

init_vhost() {
    HAS_VHOST="0"
    for EXISTING_VHOST_NAME in $EXISTING_VHOST_NAMES; do
        if [ "$EXISTING_VHOST_NAME" == "$VHOST_NAME" ]; then
            HAS_VHOST="1"
        fi
    done
    if [ "$HAS_VHOST" == "0" ]; then
        echo "Creating new vhost '$VHOST_NAME'..."
        rabbitmqctl add_vhost $VHOST_NAME
        echo "vhost '$VHOST_NAME' created."
    else
        echo "vhost '$VHOST_NAME' already exists."
    fi
}

init_user() {
    USER_NAME="$1"
    PASSWORD="$2"
    HAS_USER="0"
    for EXISTING_USER_NAME in $EXISTING_USER_NAMES; do
        if [ "$EXISTING_USER_NAME" == "$USER_NAME" ]; then
            HAS_USER="1"
        fi
    done
    if [ "$HAS_USER" == "0" ]; then
        echo "Creating new user '$USER_NAME'..."
        rabbitmqctl add_user "$USER_NAME" "$PASSWORD"
        rabbitmqctl set_permissions -p "$VHOST_NAME" "$USER_NAME" '.*' '.*' '.*'
        echo "User '$USER_NAME' created and initialized."
    else
        echo "User '$USER_NAME' already exists."
    fi
}

init_vhost "$VHOST_NAME"
init_user 'hooks' '${random_password.rabbitmq_hooks_password.result}'
init_user 'chatbot' '${random_password.rabbitmq_chatbot_password.result}'
init_user 'dispatch' '${random_password.rabbitmq_dispatch_password.result}'
echo "RabbitMQ server initialized."
EOT
  sensitive = true
}
