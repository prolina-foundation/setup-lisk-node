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

CORES=$(sysctl -n hw.ncpu 2> /dev/null || nproc 2> /dev/null || echo 1)
echo "Detected $CORES cores"

JOBS=$(( CORES * 2 ))
echo "Using $JOBS parallel restore jobs"

echo "Removing current database $TARGET_DB_NAME if it exists ..."
dropdb --if-exists "$TARGET_DB_NAME"

echo "Creating empty database $TARGET_DB_NAME ..."
createdb "$TARGET_DB_NAME"

echo "Restoring snapshot ..."
# Use --schema=public to avoid
# could not execute query: ERROR:  must be owner of extension plpgsql
# Command was: COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
pg_restore -Fcustom --schema=public --no-privileges --no-owner -j "$JOBS" -d "$TARGET_DB_NAME" "$SNAPSHOT_PATH"
