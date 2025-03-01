#!/bin/bash

# R Server Manager for Unix/Linux systems
# Equivalent to rserver.ps1 for PowerShell

# Default settings
SERVER_PORT=8080
SERVER_HOSTNAME="localhost"
WORKING_DIRECTORY="$PWD"
SERVER_PID_FILE="$HOME/.r_server.pid"
SERVER_LOG_FILE="$HOME/.r_server.log"
SERVER_LOCK_FILE="$HOME/.r_server.lock"
R_SERVER_SCRIPT="$(dirname "$(dirname "$0")")/core/r_json_server.R"

# Display usage information
show_usage() {
    echo "Usage: $0 [options] <action>"
    echo ""
    echo "Actions:"
    echo "  start      - Start the R server"
    echo "  stop       - Stop the R server"
    echo "  status     - Check if the server is running"
    echo "  restart    - Restart the server"
    echo "  execute    - Execute R code"
    echo ""
    echo "Options:"
    echo "  -p, --port <port>         - Specify the server port (default: 8080)"
    echo "  -h, --host <hostname>     - Specify the server hostname (default: localhost)"
    echo "  -w, --working-dir <dir>   - Specify the working directory"
    echo "  -c, --command <r_command> - R command to execute (with execute action)"
    echo "  -s, --script <script>     - R script to source (with execute action)"
    echo "  --help                    - Show this help message"
}

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$SERVER_LOG_FILE"
    if [ "$2" != "silent" ]; then
        echo "$1"
    fi
}

# Function to check if the server is running
test_server() {
    if [ -f "$SERVER_PID_FILE" ]; then
        SERVER_PID=$(cat "$SERVER_PID_FILE")
        if ps -p "$SERVER_PID" > /dev/null; then
            # Check if the server is responsive
            curl -s "http://$SERVER_HOSTNAME:$SERVER_PORT/ping" > /dev/null
            if [ $? -eq 0 ]; then
                return 0 # Server is running
            fi
        fi
    fi
    return 1 # Server is not running
}

# Function to start the R server
start_server() {
    # Check if server is already running
    if test_server; then
        log_message "R Server is already running. Use 'restart' to restart it."
        return 0
    fi

    # Start the server
    log_message "Starting R Server on $SERVER_HOSTNAME:$SERVER_PORT..."
    
    # Check if R is installed
    if ! command -v Rscript > /dev/null; then
        log_message "Error: Rscript not found. Please install R."
        return 1
    fi
    
    # Check if server script exists
    if [ ! -f "$R_SERVER_SCRIPT" ]; then
        log_message "Error: R server script not found: $R_SERVER_SCRIPT"
        return 1
    fi
    
    # Start the server in background
    nohup Rscript "$R_SERVER_SCRIPT" --port="$SERVER_PORT" --host="$SERVER_HOSTNAME" \
                 --wd="$WORKING_DIRECTORY" --background > /dev/null 2>&1 &
    
    SERVER_PID=$!
    echo $SERVER_PID > "$SERVER_PID_FILE"
    
    # Wait for server to start
    log_message "Waiting for server to start..."
    for i in {1..10}; do
        if curl -s "http://$SERVER_HOSTNAME:$SERVER_PORT/ping" > /dev/null; then
            log_message "R Server started successfully (PID: $SERVER_PID)"
            return 0
        fi
        sleep 1
    done
    
    # If we get here, the server didn't start properly
    log_message "Error: Failed to start R Server"
    if [ -f "$SERVER_PID_FILE" ]; then
        rm "$SERVER_PID_FILE"
    fi
    return 1
}

# Function to stop the R server
stop_server() {
    if [ ! -f "$SERVER_PID_FILE" ]; then
        log_message "R Server is not running."
        return 0
    fi
    
    SERVER_PID=$(cat "$SERVER_PID_FILE")
    log_message "Stopping R Server (PID: $SERVER_PID)..."
    
    # Try to gracefully shutdown first via HTTP request
    curl -s "http://$SERVER_HOSTNAME:$SERVER_PORT/shutdown" > /dev/null
    
    # Wait for server to shut down
    for i in {1..5}; do
        if ! ps -p "$SERVER_PID" > /dev/null; then
            log_message "R Server stopped successfully"
            rm "$SERVER_PID_FILE"
            return 0
        fi
        sleep 1
    done
    
    # Forcefully terminate if still running
    log_message "Forcefully terminating R Server..."
    kill -9 "$SERVER_PID" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_message "R Server terminated"
        rm "$SERVER_PID_FILE"
        return 0
    else
        log_message "Error: Failed to terminate R Server"
        return 1
    fi
}

# Function to restart the server
restart_server() {
    stop_server
    start_server
}

# Function to get server status
get_server_status() {
    if test_server; then
        SERVER_PID=$(cat "$SERVER_PID_FILE")
        echo "R Server is running (PID: $SERVER_PID, Port: $SERVER_PORT)"
        return 0
    else
        echo "R Server is not running"
        if [ -f "$SERVER_PID_FILE" ]; then
            rm "$SERVER_PID_FILE"
        fi
        return 1
    fi
}

# Function to execute R code
execute_r_code() {
    local r_code="$1"
    local json_data="{\"code\": \"$r_code\"}"
    
    # Ensure server is running
    if ! test_server; then
        log_message "Starting R Server for command execution..."
        start_server
        
        if ! test_server; then
            log_message "Error: Failed to start R Server"
            return 1
        fi
    fi
    
    # Send the request
    local response
    response=$(curl -s -X POST "http://$SERVER_HOSTNAME:$SERVER_PORT/execute" \
               -H "Content-Type: application/json" -d "$json_data")
    
    # Output the response
    echo "$response"
    return 0
}

# Function to source an R script
source_r_script() {
    local script_path="$1"
    
    # Check if file exists
    if [ ! -f "$script_path" ]; then
        log_message "Error: Script file not found: $script_path"
        return 1
    fi
    
    # Read script content
    local script_content=$(cat "$script_path" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ')
    
    # Execute the script
    execute_r_code "$script_content"
}

# Parse command line arguments
ACTION=""
R_COMMAND=""
R_SCRIPT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        start|stop|status|restart|execute)
            ACTION="$1"
            shift
            ;;
        -p|--port)
            SERVER_PORT="$2"
            shift 2
            ;;
        -h|--host)
            SERVER_HOSTNAME="$2"
            shift 2
            ;;
        -w|--working-dir)
            WORKING_DIRECTORY="$2"
            shift 2
            ;;
        -c|--command)
            R_COMMAND="$2"
            shift 2
            ;;
        -s|--script)
            R_SCRIPT="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main action
if [ -z "$ACTION" ]; then
    echo "Error: No action specified"
    show_usage
    exit 1
fi

case "$ACTION" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    status)
        get_server_status
        ;;
    restart)
        restart_server
        ;;
    execute)
        if [ ! -z "$R_COMMAND" ]; then
            execute_r_code "$R_COMMAND"
        elif [ ! -z "$R_SCRIPT" ]; then
            source_r_script "$R_SCRIPT"
        else
            echo "Error: No R command or script specified for execution"
            show_usage
            exit 1
        fi
        ;;
esac

exit $? 