#!/bin/bash

# R JSON Client for Unix/Linux systems
# Equivalent to r_json_client.ps1 for PowerShell

# Default settings
SERVER_PORT=8080
SERVER_HOSTNAME="localhost"
LOG_FILE="$HOME/.r_json_client.log"
SERVER_PID_FILE="$HOME/.r_server.pid"
SERVER_LOG_FILE="$HOME/.r_server.log"
SERVER_LOCK_FILE="$HOME/.r_server.lock"

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

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    if [ "$2" != "silent" ]; then
        echo "$1"
    fi
}

# Function to send a request to the R server
send_request() {
    local endpoint="$1"
    local data="$2"
    
    # Ensure server is running
    if ! test_server; then
        log_message "Error: R Server is not running. Use 'rserver.sh start' to start it."
        return 1
    fi
    
    # Send the request
    local response
    if [ -z "$data" ]; then
        response=$(curl -s "http://$SERVER_HOSTNAME:$SERVER_PORT/$endpoint")
    else
        response=$(curl -s -X POST "http://$SERVER_HOSTNAME:$SERVER_PORT/$endpoint" \
            -H "Content-Type: application/json" -d "$data")
    fi
    
    # Check for errors
    if [ $? -ne 0 ]; then
        log_message "Error: Failed to communicate with R server"
        return 1
    fi
    
    # Output the response
    echo "$response"
    return 0
}

# Function to execute R code
execute_r_code() {
    local r_code="$1"
    local json_data="{\"code\": \"$r_code\"}"
    
    send_request "execute" "$json_data"
}

# Function to source an R script
source_r_script() {
    local script_path="$1"
    
    # Check if file exists
    if [ ! -f "$script_path" ]; then
        log_message "Error: Script file not found: $script_path"
        return 1
    fi
    
    # Escape the file content for JSON
    local script_content=$(cat "$script_path" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ')
    local json_data="{\"code\": \"$script_content\"}"
    
    send_request "execute" "$json_data"
}

# Function to load a package
load_package() {
    local package_name="$1"
    local r_code="if (!require($package_name, quietly=TRUE)) { install.packages('$package_name', repos='https://cran.rstudio.com/'); library($package_name) } else { library($package_name) }"
    
    execute_r_code "$r_code"
}

# Function to get the working directory
get_working_directory() {
    send_request "getwd" ""
}

# Function to set the working directory
set_working_directory() {
    local directory="$1"
    local json_data="{\"directory\": \"$directory\"}"
    
    send_request "setwd" "$json_data"
}

# Function to get server status
get_server_status() {
    if test_server; then
        echo "R Server is running"
        return 0
    else
        echo "R Server is not running"
        return 1
    fi
}

# Main function to handle command-line arguments
main() {
    case "$1" in
        execute|exec)
            shift
            execute_r_code "$*"
            ;;
        source)
            source_r_script "$2"
            ;;
        load)
            load_package "$2"
            ;;
        getwd)
            get_working_directory
            ;;
        setwd)
            set_working_directory "$2"
            ;;
        status)
            get_server_status
            ;;
        help|--help|-h)
            echo "Usage: $0 <command> [arguments]"
            echo "Commands:"
            echo "  execute|exec <r_code>  - Execute R code"
            echo "  source <script_path>   - Source an R script"
            echo "  load <package_name>    - Load an R package"
            echo "  getwd                  - Get the current working directory"
            echo "  setwd <directory>      - Set the working directory"
            echo "  status                 - Check if the R server is running"
            echo "  help                   - Show this help message"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            return 1
            ;;
    esac
}

# Make the script executable if it's being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 