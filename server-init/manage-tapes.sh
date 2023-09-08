#!/usr/bin/env bash
set -e

REPO_NAME="tapes"

COMMAND=""
case "$1" in
install) COMMAND="install" ;;
up) COMMAND="up" ;;
down) COMMAND="down" ;;
esac

if [ "$COMMAND" == "" ]; then
    echo "ERROR: Must provide a valid command (install|up|down)"
    exit 1
fi

if [ "$COMMAND" == "install" ]; then
    if [ -d "$REPO_NAME" ]; then
        git --git-dir="$REPO_NAME" pull
    else
        git clone "https://github.com/golden-vcr/$REPO_NAME.git"
    fi
fi

if [ "$COMMAND" == "up" ]; then
    cd $REPO_NAME
    go build -o "bin/$REPO_NAME" "cmd/server/main.go"
    cd bin
    mkdir -p /var/log/gvcr
    "./$REPO_NAME" >> "/var/log/gvcr/$REPO_NAME.log" 2>&1 &
    PID=$!
    echo "PID $PID"
fi

if [ "$COMMAND" == "down" ]; then
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
fi
