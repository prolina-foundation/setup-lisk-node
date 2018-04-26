#!/bin/bash
set -o errexit -o nounset -o pipefail

PUBKEY_FILE="$HOME/.lisk_node/pubkey"
SECRET_FILE="$HOME/.lisk_node/secret"

echo "Reading pubkey from file $PUBKEY_FILE ..."
PUBKEY=$(<"$PUBKEY_FILE")

if [ -z "$PUBKEY" ]; then
    echo "pubkey is empty, stopping."
    exit 1
fi

echo "Reading secret from file $SECRET_FILE ..."
SECRET=$(<"$SECRET_FILE")

if [ -z "$SECRET" ]; then
    echo "secret is empty, stopping."
    exit 1
fi

# {{ lisk_node_api_port }} will be replaced beforre this becomes a script, thus
# we disable shellcheck warnings in order to be able to check the template
# shellcheck disable=SC1083
RETURN_JSON=$(curl \
    --silent --show-error \
    -X PUT \
    -H "Content-Type: application/json" \
    -d "{\"publicKey\": \"$PUBKEY\", \"decryptionKey\": \"$SECRET\"}" \
    http://localhost:{{ lisk_node_api_port }}/api/node/status/forging
)

SUCCESS=$(echo "$RETURN_JSON" | jq .success)

if [[ "$SUCCESS" != "true" ]]; then
    echo "API reported error:"
    echo "$RETURN_JSON"
    exit 1
fi
