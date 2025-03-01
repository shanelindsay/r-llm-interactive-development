#!/bin/bash

# R Command - Unix/Linux version
# Simple wrapper to execute R commands through the R JSON server

# Default settings
SCRIPT_DIR="$(dirname "$0")"
CLIENT_SCRIPT="$SCRIPT_DIR/r_json_client.sh"

# Check if client script exists
if [ ! -f "$CLIENT_SCRIPT" ]; then
    echo "Error: R JSON client script not found: $CLIENT_SCRIPT"
    exit 1
fi

# Make client script executable if it's not already
if [ ! -x "$CLIENT_SCRIPT" ]; then
    chmod +x "$CLIENT_SCRIPT"
fi

# Check if we have any arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <r_command>"
    echo "Example: $0 'print(1+1)'"
    exit 1
fi

# Join all arguments into a single R command
R_COMMAND="$*"

# Execute the command through the client
"$CLIENT_SCRIPT" execute "$R_COMMAND"

exit $? 