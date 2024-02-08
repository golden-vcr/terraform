#!/usr/bin/env bash
# Quick-and-dirty script for reconciling data in the 'showtime' database schema with the
# newer 'broadcasts' schema. Syncs all rows in the 'broadcast' and 'screening' tables
# from the former to the latter. Designed to be run on demand via SSH, as the postgres
# user (e.g. 'sudo -u postgres ./migrate-from-showtime-to-broadcasts.sh')
set -e
psql -v ON_ERROR_STOP=1 -d showtime -qtAX -f dump-broadcasts-data-from-showtime.sql | psql -v ON_ERROR_STOP=1 -1 -d broadcasts
psql -v ON_ERROR_STOP=1 -d broadcasts -c "SELECT setval(pg_get_serial_sequence('broadcasts.broadcast', 'id'), COALESCE(max(id) + 1, 1), false) FROM broadcasts.broadcast;"
