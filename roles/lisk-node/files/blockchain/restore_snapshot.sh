#!/bin/bash
set -o errexit -o nounset -o pipefail
which shellcheck > /dev/null && (shellcheck -x "$0" || shellcheck "$0")

function print_usage() {
    echo "$0 DB_NAME SNAPSHOT_PATH"
}

if [ "$#" -ne 2 ]; then
    print_usage
    exit 1
fi

TARGET_DB_NAME="$1"
SNAPSHOT_PATH="$2"

echo "Removing current database $TARGET_DB_NAME if it exists ..."
dropdb --if-exists "$TARGET_DB_NAME"

echo "Creating empty database $TARGET_DB_NAME ..."
createdb "$TARGET_DB_NAME"

echo "Restoring snapshot ..."
gunzip -fcq "$SNAPSHOT_PATH" | psql --quiet --dbname "$TARGET_DB_NAME"
