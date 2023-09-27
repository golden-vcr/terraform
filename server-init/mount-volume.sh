#!/usr/bin/env bash

GVCR_DATA_VOLUME=/dev/disk/by-id/scsi-0DO_Volume_gvcr-data
GVCR_DATA_MOUNT=/mnt/gvcr_data

findmnt "$GVCR_DATA_MOUNT"
if [ "$?" == "0" ]; then
    echo "$GVCR_DATA_VOLUME is mounted at $GVCR_DATA_MOUNT."
    exit
fi

set -e
echo "Creating $GVCR_DATA_MOUNT and mounting $GVCR_DATA_VOLUME..."
rm -rf "$GVCR_DATA_MOUNT"
mkdir -p "$GVCR_DATA_MOUNT"
mount -o defaults,nofail,discard,noatime $GVCR_DATA_VOLUME $GVCR_DATA_MOUNT
echo "$GVCR_DATA_VOLUME $GVCR_DATA_MOUNT ext4 defaults,nofail,discard,noatime 0 0" | tee /etc/fstab
findmnt "$GVCR_DATA_MOUNT"
echo "Mounted volume."
