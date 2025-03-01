#!/bin/bash

# Start R JSON Server - Unix/Linux version
# Simple script to start the R JSON server

# Get script directory
SCRIPT_DIR="$(dirname "$0")"
SERVER_SCRIPT="$SCRIPT_DIR/rserver.sh"

# Make the server script executable if it's not already
if [ ! -x "$SERVER_SCRIPT" ]; then
    chmod +x "$SERVER_SCRIPT"
fi

# Start the server
"$SERVER_SCRIPT" start

# Check if server started successfully
if [ $? -eq 0 ]; then
    echo "R JSON Server started successfully."
else
    echo "Failed to start R JSON Server. Check logs for details."
fi 