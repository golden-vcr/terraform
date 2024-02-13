#!/usr/bin/env bash
# Quick-and-dirty script for reconciling data in the 'showtime' database schema with the
# newer 'dynamo' schema. Syncs all rows in the 'image_request' and 'image' tables from
# the former to the latter. Designed to be run on demand via SSH, as the postgres user
# (e.g. 'sudo -u postgres ./migrate-from-showtime-to-dynamo.sh')
set -e
psql -v ON_ERROR_STOP=1 -d showtime -qtAX -f dump-dynamo-data-from-showtime.sql | psql -v ON_ERROR_STOP=1 -1 -d dynamo
