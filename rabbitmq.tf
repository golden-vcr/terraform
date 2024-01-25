resource "random_password" "rabbitmq_hooks_password" {
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

output "hooks_rabbitmq_env" {
  value     = <<EOT
RMQ_HOST=${digitalocean_droplet.rabbitmq_server.ipv4_address_private}
RMQ_PORT=5672
RMQ_VHOST=gvcr
RMQ_USER=hooks
RMQ_PASSWORD='${random_password.rabbitmq_hooks_password.result}'
EOT
  sensitive = true
}

output "dispatch_rabbitmq_env" {
  value     = <<EOT
RMQ_HOST=${digitalocean_droplet.rabbitmq_server.ipv4_address_private}
RMQ_PORT=5672
RMQ_VHOST=gvcr
RMQ_USER=dispatch
RMQ_PASSWORD='${random_password.rabbitmq_dispatch_password.result}'
EOT
  sensitive = true
}

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
init_user 'dispatch' '${random_password.rabbitmq_dispatch_password.result}'
echo "RabbitMQ server initialized."
EOT
  sensitive = true
}
