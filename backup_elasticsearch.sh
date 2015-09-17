#!/bin/bash
# Script to create full snapshots every Sunday evening and run incrementals for the remainder of the week
# This is intended to be run as a nightly cronjob
if [[ $(date +%u) -lt 7 ]] ; then
   DATE=$(date -dlast-sunday +%Y-%m-%d);
   else DATE=$(date +%Y-%m-%d);
fi
TIMESTAMP=$(date +%Y%m%d%H%M)
BASE_PATH_NAME="/$HOSTNAME/$DATE"

# Set the snapshot repository
/usr/bin/curl -XPUT 'http://localhost:9200/_snapshot/es_s3_repository' -d '{
     "type": "s3",
     "settings": {
         "bucket": "elasticsearch-backups",
         "region": "us-east-1",
         "base_path": "'$BASE_PATH_NAME'"
     }
}'

# Take the ES snapshot
/usr/bin/curl -XPUT "http://localhost:9200/_snapshot/es_s3_repository/snapshot_$TIMESTAMP?wait_for_completion=true"
