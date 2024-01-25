#!/usr/bin/env bash
set -e

REPO_NAME="$1"
COMMAND=""
case "$2" in
install) COMMAND="install" ;;
up) COMMAND="up" ;;
down) COMMAND="down" ;;
update) COMMAND="update" ;;
esac

ENV_FILE_PATH=""
if [ "$3" != "" ]; then
    ENV_FILE_PATH=$(realpath "$3")
fi

run_install() {
    if [ -d "$REPO_NAME" ]; then
        (cd "$REPO_NAME" && git pull)
    else
        git clone "https://github.com/golden-vcr/$REPO_NAME.git"
    fi   
}

run_up() {
    cd $REPO_NAME
    if [ "$ENV_FILE_PATH" != "" ]; then
        mkdir -p bin
        mv "$ENV_FILE_PATH" bin/.env
    fi

    if [ -f db-migrate.sh ]; then
        echo "Running database migrations for $REPO_NAME..."
        ./db-migrate.sh
    fi

    if [ -f cmd/sync/main.go ]; then
        echo "Building $REPO_NAME-sync binary..."
        go build -o "bin/$REPO_NAME-sync" "cmd/sync/main.go"
    fi

    if [ -f cmd/consumer/main.go ]; then
        echo "Building $REPO_NAME-consumer binary..."
        go build -o "bin/$REPO_NAME-consumer" "cmd/consumer/main.go"
        cd bin
        mkdir -p /var/log/gvcr
        "./$REPO_NAME-consumer" > "/var/log/gvcr/$REPO_NAME-consumer.log" 2>&1 &
        PID=$!
        echo "PID $PID"
        cd ..
    fi

    if [ -f cmd/server/main.go ]; then
        echo "Building $REPO_NAME server binary..."
        go build -o "bin/$REPO_NAME" "cmd/server/main.go"
        cd bin
        mkdir -p /var/log/gvcr
        "./$REPO_NAME" > "/var/log/gvcr/$REPO_NAME.log" 2>&1 &
        PID=$!
        echo "PID $PID"
        cd ..
    fi
}

run_down() {
    set +e
    PIDS=$(pgrep -x "$REPO_NAME-?.*")
    PGREP_EXITCODE=$?
    set -e
    if [ $PGREP_EXITCODE -eq 0 ]; then
        for PID in $PIDS; do
            echo "Killing $REPO_NAME ($PID)..."
            kill "$PID"
        done
    else
        echo "$REPO_NAME is not running."
    fi
}

if [ "$REPO_NAME" == "" ] || [ "$COMMAND" == "" ]; then
    echo "Usage: ./manage.sh [repo] [install|up|down|update]"
    exit 1
fi

if [ "$COMMAND" == "install" ]; then
    run_install
fi

if [ "$COMMAND" == "up" ]; then
    run_up
fi

if [ "$COMMAND" == "down" ]; then
    run_down
fi

if [ "$COMMAND" == "update" ]; then
    run_down
    run_install
    run_up
fi
