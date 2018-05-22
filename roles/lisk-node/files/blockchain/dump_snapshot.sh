#!/bin/bash
set -o errexit -o nounset -o pipefail
which shellcheck > /dev/null && (shellcheck -x "$0" || shellcheck "$0")

function print_usage() {
    echo "$0 DB_NAME"
}

if [ "$#" -ne 1 ]; then
    print_usage
    exit 1
fi

ORIGINAL_DB_NAME="$1"
SNAPSHOT_TIME="$(date --utc +%Y-%m-%dT%H-%M-%SZ)"
SNAPSHOT_DB_NAME="${ORIGINAL_DB_NAME}_snapshot${SNAPSHOT_TIME}_pid$$"

# Copy database into snapshot database to allow changes to the data
echo "Copy data into snapshot database $SNAPSHOT_DB_NAME ..."
createdb "$SNAPSHOT_DB_NAME"
pg_dump "$ORIGINAL_DB_NAME" | psql "$SNAPSHOT_DB_NAME"

echo "Deleting peers from snapshot data ..."
psql -d "$SNAPSHOT_DB_NAME" -c 'delete from peers;'

HEIGHT=$(psql -d "$SNAPSHOT_DB_NAME" -t -c 'SELECT height FROM blocks ORDER BY height DESC LIMIT 1;' | xargs)
echo "Snapshot height is $HEIGHT"

SNAPSHOT_FILE_NAME="${ORIGINAL_DB_NAME}_h${HEIGHT}_${SNAPSHOT_TIME}.gz"

echo "Dumping snapshot to file $SNAPSHOT_FILE_NAME ..."
pg_dump --no-owner "$SNAPSHOT_DB_NAME" | gzip > "$SNAPSHOT_FILE_NAME"

echo "Removing snapshot database ..."
dropdb "$SNAPSHOT_DB_NAME"
