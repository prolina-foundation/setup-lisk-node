#!/bin/bash
set -o errexit -o nounset -o pipefail

SECRET_FILE="$HOME/.lisk_node/secret"

echo "Reading secret from file $SECRET_FILE ..."
SECRET=$(<"$SECRET_FILE")

# {{ lisk_node_api_port }} will be replaced beforre this becomes a script, thus
# we disable shellcheck warnings in order to be able to check the template
# shellcheck disable=SC1083
RETURN_JSON=$(curl \
    --silent --show-error \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{\"secret\": \"$SECRET\"}" \
    http://localhost:{{ lisk_node_api_port }}/api/delegates/forging/disable
)

SUCCESS=$(echo "$RETURN_JSON" | jq .success)

if [[ "$SUCCESS" != "true" ]]; then
    echo "API reported error:"
    echo "$RETURN_JSON"
    exit 1
fi
