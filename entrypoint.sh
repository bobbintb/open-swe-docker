#!/bin/sh
set -e

# Check PEM file
if [ ! -f /open-swe/key.pem ]; then
  echo "ERROR: /open-swe/key.pem not found!" >&2
  exit 1
fi

# Load PEM into environment
export GITHUB_APP_PRIVATE_KEY="$(cat /open-swe/key.pem)"

# Start both dev servers in background
cd "$OPENSWE_DIR" && yarn dev &
cd "$WEB_DIR" && yarn dev &
wait
