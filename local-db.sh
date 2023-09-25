#!/usr/bin/env bash
set -e

POSTGRES_IMAGE='postgres:16'
CONTAINER_NAME='gvcr-postgres'
USERNAME='gvcr'
PASSWORD='password'
PORT='5432'

if [ "$1" == "env" ]; then
    echo "PGHOST=127.0.0.1"
    echo "PGPORT=$PORT"
    echo "PGDATABASE=$USERNAME"
    echo "PGUSER=$USERNAME"
    echo "PGPASSWORD='$PASSWORD'"
    echo "PGSSLMODE=disable"
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
    echo "Starting $CONTAINER_NAME, running $POSTGRES_IMAGE..."
    docker run \
        -d \
        --rm \
        --name "$CONTAINER_NAME" \
        -e "POSTGRES_USER=$USERNAME" \
        -e "POSTGRES_PASSWORD=$PASSWORD" \
        -p "$PORT:5432" \
        "$POSTGRES_IMAGE"
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

echo "Usage: local-db.sh [env|up|down|logs]"
exit 1
