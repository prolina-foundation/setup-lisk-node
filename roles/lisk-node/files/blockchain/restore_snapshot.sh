#!/bin/bash
set -o errexit -o nounset -o pipefail
which shellcheck > /dev/null && (shellcheck -x "$0" || shellcheck "$0")

SNAPSHOT_PATH="$1"

TARGET_DB_NAME="lisk_test"

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
