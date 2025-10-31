#!/bin/bash
# Using /bin/bash is required for 'wait -n' and 'pids' array

# Exit immediately if a command fails
set -e

# --- 1. Environment Setup ---
if [ ! -f /open-swe/key.pem ]; then
  echo "ERROR: /open-swe/key.pem not found!" >&2
  exit 1
fi

echo "Loading GITHUB_APP_PRIVATE_KEY..."
export GITHUB_APP_PRIVATE_KEY="$(cat /open-swe/key.pem)"

# Array to hold the Process IDs (PIDs) of our servers
pids=()

# --- 2. Graceful Shutdown Function ---
# This function will be called when the container gets a stop signal
shutdown() {
  echo "Shutting down servers..."
  # Kill all PIDs stored in the 'pids' array
  for pid in "${pids[@]}"; do
    kill "$pid"
  done
  echo "Shutdown complete."
}

# 'trap' tells the script to call our 'shutdown' function
# when it receives a SIGTERM (from 'docker stop') or SIGINT (from Ctrl+C)
trap shutdown TERM INT

# --- 3. Start Servers ---
echo "Starting OpenSWE server..."
cd "$OPENSWE_DIR"
yarn dev &
pids+=($!) # Save the PID of the last background process

echo "Starting Web server..."
cd "$WEB_DIR"
yarn dev &
pids+=($!) # Save the PID

# --- 4. Wait for Servers ---
echo "Servers running (PIDs: ${pids[*]}). Waiting..."

# 'wait -n' is the magic:
# It waits for the *next* (any) background process to exit.
#
# - If a server crashes, 'wait -n' exits, 'set -e' sees the error,
#   and the whole script stops (which stops the container).
# - If a 'docker stop' signal is received, the 'trap' runs,
#   kills the servers, 'wait -n' unblocks, and the script exits.
wait -n

exit $?
