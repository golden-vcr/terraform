#!/usr/bin/env bash
set -e

# Automatically manage backups, deleting older backups to save space and forget data
DUMPS_DIR="/mnt/gvcr_data/pgdumps"
NUM_AUTOMATIC_DUMPS_TO_RETAIN=14
clean_dumps() {
    echo "Ensuring that no more than $NUM_AUTOMATIC_DUMPS_TO_RETAIN automatic dumps are retained..."
    NUM_KEPT=0
    NUM_DELETED=0
    for DUMP_FILE in $(ls -1 "$DUMPS_DIR" | grep -vF '_' | sort | tac); do
        if [ $NUM_KEPT -ge $NUM_AUTOMATIC_DUMPS_TO_RETAIN ]; then
            echo "Deleting $DUMP_FILE"
            rm "$DUMPS_DIR/$DUMP_FILE"
            NUM_DELETED=$((NUM_DELETED+1))
        else
            echo "Keeping $DUMP_FILE"
            NUM_KEPT=$((NUM_KEPT+1))
        fi
    done
    echo "Kept $NUM_KEPT most recent backups; deleted $NUM_DELETED."
}

# Stop and start applications that connect to the database while restoring backups
APPLICATIONS_WITH_DB_ACCESS="tapes showtime"
APPLICATIONS_STOPPED="0"
stop_applications() {
    APPLICATIONS_STOPPED="1"
    echo "Stopping applications that connect to the database..."
    for APPLICATION in $APPLICATIONS_WITH_DB_ACCESS; do
        ./manage.sh "$APPLICATION" down
    done
}
restart_applications() {
    if [ "$APPLICATIONS_STOPPED" == "1" ]; then
        echo "Restarting applications that connect to the database..."
        for APPLICATION in $APPLICATIONS_WITH_DB_ACCESS; do
            ./manage.sh "$APPLICATION" up
        done
        APPLICATIONS_STOPPED="0"
    fi
}
trap restart_applications EXIT

# Ensure that the dump directory exists and is owned by postgres
mkdir -p "$DUMPS_DIR"
chown postgres:postgres "$DUMPS_DIR"
chmod 700 "$DUMPS_DIR"

# Generate a new dump, cleaning up old dumps if run nightly
if [ "$1" == "generate" ]; then
    mkdir -p "$DUMPS_DIR"
    DUMP_NAME=$(date '+%Y-%m-%d-%H%M%S')
    if [ "$2" != "" ]; then
        DUMP_NAME="${DUMP_NAME}_$2"
    fi
    DUMP_PATH="$DUMPS_DIR/$DUMP_NAME.sql"
    sudo -u postgres pg_dumpall --verbose --clean --file "$DUMP_PATH"
    sed -i -E '/(CREATE|DROP) ROLE postgres;/d' "$DUMP_PATH"
    echo "Generated $DUMP_PATH."
    if [ "$2" != "" ]; then
        echo "NOTE: Dumps generated with a label ($2) will not be automatically cleaned up."
    else
        clean_dumps
    fi
    exit
fi

# Restore a dump from a file, wiping any existing db state
if [ "$1" == "restore" ]; then
    DUMP_PATH="$2"
    if [ "$DUMP_PATH" == "" ] || [  ]; then
        echo "Usage: ./db-dump.sh restore <dump-path>"
        exit 1
    fi
    stop_applications
    sudo -u postgres psql -v ON_ERROR_STOP=1 < "$DUMP_PATH"
    exit
fi

echo "Usage: ./db-dump.sh generate"
echo "       ./db-dump.sh restore <dump-path>"
exit 1
