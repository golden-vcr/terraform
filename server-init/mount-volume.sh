#!/usr/bin/env bash
set -e

GVCR_DATA_VOLUME=/dev/disk/by-id/scsi-0DO_Volume_gvcr-data
GVCR_DATA_MOUNT=/mnt/gvcr_data

if [ -d $GVCR_DATA_MOUNT ]; then
    echo "$GVCR_DATA_VOLUME is mounted at $GVCR_DATA_MOUNT."
    exit
fi

echo "Creating $GVCR_DATA_MOUNT and mounting $GVCR_DATA_VOLUME..."
mkdir -p /mnt/gvcr_data
mount -o discard,defaults,noatime $GVCR_DATA_VOLUME $GVCR_DATA_MOUNT
echo "$GVCR_DATA_VOLUME $GVCR_DATA_MOUNT ext4 defaults,nofail,discard 0 0" | tee /etc/fstab
echo "Mounted volume."
