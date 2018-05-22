#!/bin/bash
set -o errexit -o nounset -o pipefail
which shellcheck > /dev/null && (shellcheck -x "$0" || shellcheck "$0")

DIR=$(mktemp -d)
(
    echo "Using temp dir $DIR ..."
    cd "$DIR"
    /workspace/dump_snapshot.sh {{ blockchain_database_name }}
    FILES=(*.gz); FILE="${FILES[0]}"; sha256sum "$FILE" > "$FILE.sha256"
    mv ./* /workspace/snapshots
)

echo "Removing temp dir $DIR ..."
rm -r "$DIR"
