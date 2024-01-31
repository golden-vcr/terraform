#!/usr/bin/env bash
set -e

RABBITMQ_IMAGE='rabbitmq:3'
CONTAINER_NAME='gvcr-rabbitmq'
CONTAINER_HOSTNAME='gvcr-rabbitmq'
PORT='5672'
VHOST_NAME='gvcr'

if [ "$1" == "env" ]; then
    echo "RMQ_HOST=127.0.0.1"
    echo "RMQ_PORT=$PORT"
    echo "RMQ_VHOST=$VHOST_NAME"
    echo "RMQ_USER=guest"
    echo "RMQ_PASSWORD=guest"
    exit
fi

if [ "$1" == "up" ]; then
    CURRENT_STATE=$(docker ps -f "name=$CONTAINER_NAME" --format '{{.State}}')
    if [ "$CURRENT_STATE" == "running" ]; then
        echo "$CONTAINER_NAME is running."
        exit
    fi
    if [ "$CURRENT_STATE" != "" ]; then
        echo "$CONTAINER_NAME is in state '$CURRENT_STATE'; stopping it..."
        docker stop "$CONTAINER_NAME"
    fi
    echo "Starting $CONTAINER_NAME, running $RABBITMQ_IMAGE..."
    docker run \
        -d \
        --rm \
        --hostname "$CONTAINER_HOSTNAME" \
        --name "$CONTAINER_NAME" \
        -p "$PORT:5672" \
        -e "RABBITMQ_DEFAULT_VHOST=$VHOST_NAME" \
        "$RABBITMQ_IMAGE"
    exit
fi

if [ "$1" == "down" ]; then
    CURRENT_STATE=$(docker ps -f "name=$CONTAINER_NAME" --format '{{.State}}')
    if [ "$CURRENT_STATE" == "" ]; then
        echo "$CONTAINER_NAME does not exist."
        exit
    fi
    echo "Stopping $CONTAINER_NAME..."
    docker stop "$CONTAINER_NAME"
    exit
fi

if [ "$1" == "logs" ]; then
    CURRENT_STATE=$(docker ps -f "name=$CONTAINER_NAME" --format '{{.State}}')
    if [ "$CURRENT_STATE" != "running" ]; then
        echo "$CONTAINER_NAME is not running."
        exit 1
    fi
    docker logs -f "$CONTAINER_NAME"
    exit
fi

echo "Usage: local-rmq.sh [env|up|down|logs]"
exit 1
