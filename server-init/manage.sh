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
    go build -o "bin/$REPO_NAME" "cmd/server/main.go"
    cd bin
    if [ "$ENV_FILE_PATH" != "" ]; then
        mv "$ENV_FILE_PATH" ./.env
    fi
    mkdir -p /var/log/gvcr
    "./$REPO_NAME" > "/var/log/gvcr/$REPO_NAME.log" 2>&1 &
    PID=$!
    echo "PID $PID"
}

run_down() {
    set +e
    PIDS=$(pgrep -x "$REPO_NAME")
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
