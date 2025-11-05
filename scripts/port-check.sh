#!/bin/bash

#############################################################################
# Script Name: port-check.sh
# Description: Check if ports are open/listening
# Usage: ./port-check.sh [port1] [port2] ...
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") [ports...]

Check if specified ports are open and listening.

ARGUMENTS:
    ports       List of ports to check (optional)
                If not provided, shows all listening ports

OPTIONS:
    -h, --help  Show this help message
    -a, --all   Show all listening ports (default if no ports specified)

EXAMPLES:
    $(basename "$0")              # Show all listening ports
    $(basename "$0") 80 443       # Check if ports 80 and 443 are open
    $(basename "$0") 22 3306 5432 # Check multiple ports
EOF
    exit 0
}

show_all_ports() {
    echo -e "${BLUE}All Listening Ports:${NC}"
    echo "========================================"
    
    if command -v ss &> /dev/null; then
        echo "Proto  Local Address           Process"
        ss -tulpn 2>/dev/null | grep LISTEN | awk '{print $1 "  " $5 "  " $7}' | column -t
    elif command -v netstat &> /dev/null; then
        netstat -tulpn 2>/dev/null | grep LISTEN
    else
        echo "Error: Neither ss nor netstat command found"
        exit 1
    fi
}

check_port() {
    local port=$1
    local is_listening=false
    local process_info=""
    
    # Validate port number
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}Invalid port number: $port${NC}"
        return
    fi
    
    # Check using ss (preferred)
    if command -v ss &> /dev/null; then
        local result=$(ss -tulpn 2>/dev/null | grep ":$port " | grep LISTEN)
        if [ -n "$result" ]; then
            is_listening=true
            process_info=$(echo "$result" | awk '{print $1 "  " $5 "  " $7}')
        fi
    # Fall back to netstat
    elif command -v netstat &> /dev/null; then
        local result=$(netstat -tulpn 2>/dev/null | grep ":$port " | grep LISTEN)
        if [ -n "$result" ]; then
            is_listening=true
            process_info=$(echo "$result" | awk '{print $1 "  " $4 "  " $7}')
        fi
    # Try lsof as last resort
    elif command -v lsof &> /dev/null; then
        local result=$(lsof -i ":$port" -sTCP:LISTEN 2>/dev/null)
        if [ -n "$result" ]; then
            is_listening=true
            process_info=$(echo "$result" | tail -n +2)
        fi
    fi
    
    # Display result
    if [ "$is_listening" = true ]; then
        echo -e "${GREEN}✓${NC} Port $port is ${GREEN}OPEN${NC}"
        if [ -n "$process_info" ]; then
            echo "$process_info" | sed 's/^/  /'
        fi
    else
        echo -e "${RED}✗${NC} Port $port is ${RED}CLOSED${NC} or not listening"
    fi
    echo ""
}

# Parse arguments
case "$1" in
    -h|--help)
        show_help
        ;;
    -a|--all)
        show_all_ports
        exit 0
        ;;
esac

# If no ports specified, show all
if [ $# -eq 0 ]; then
    show_all_ports
    exit 0
fi

# Check specified ports
echo -e "${BLUE}Port Status Check${NC}"
echo "========================================"
echo ""

for port in "$@"; do
    check_port "$port"
done

echo "========================================"
echo "Check completed for $# port(s)"
