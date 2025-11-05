#!/bin/bash

#############################################################################
# Script Name: service-status.sh
# Description: Check status of critical services
# Usage: ./service-status.sh [service1] [service2] ...
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Common critical services to check
DEFAULT_SERVICES=("sshd" "cron" "rsyslog")

show_help() {
    cat << EOF
Usage: $(basename "$0") [services...]

Check status of system services.

ARGUMENTS:
    services    List of services to check (optional)
                If not provided, checks: ${DEFAULT_SERVICES[*]}

OPTIONS:
    -h, --help  Show this help message
    -a, --all   List all running services

EXAMPLES:
    $(basename "$0")                  # Check default critical services
    $(basename "$0") nginx mysql      # Check specific services
    $(basename "$0") -a               # List all running services
EOF
    exit 0
}

list_all_services() {
    echo -e "${BLUE}All Running Services:${NC}"
    echo "========================================"
    
    if command -v systemctl &> /dev/null; then
        systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | sort
    elif command -v service &> /dev/null; then
        service --status-all 2>&1 | grep '\[ + \]' | awk '{print $4}'
    else
        echo "Error: Unable to determine service manager"
        exit 1
    fi
    exit 0
}

check_service() {
    local service=$1
    local status_output
    local is_running=false
    
    # Try systemctl first (systemd)
    if command -v systemctl &> /dev/null; then
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            is_running=true
            status_output=$(systemctl status "$service" --no-pager -l 2>&1 | head -3 | tail -2)
        fi
    # Try service command (SysV init)
    elif command -v service &> /dev/null; then
        if service "$service" status &> /dev/null; then
            is_running=true
            status_output=$(service "$service" status 2>&1 | head -2)
        fi
    fi
    
    # Display status
    if [ "$is_running" = true ]; then
        echo -e "${GREEN}✓${NC} $service is ${GREEN}running${NC}"
        if [ -n "$status_output" ]; then
            echo "$status_output" | sed 's/^/  /'
        fi
    else
        echo -e "${RED}✗${NC} $service is ${RED}not running${NC}"
    fi
    echo ""
}

# Parse arguments
case "$1" in
    -h|--help)
        show_help
        ;;
    -a|--all)
        list_all_services
        ;;
esac

# Determine which services to check
if [ $# -eq 0 ]; then
    SERVICES=("${DEFAULT_SERVICES[@]}")
else
    SERVICES=("$@")
fi

echo -e "${BLUE}Service Status Check${NC}"
echo "========================================"
echo ""

# Check each service
for service in "${SERVICES[@]}"; do
    check_service "$service"
done

# Summary
echo "========================================"
echo "Check completed for ${#SERVICES[@]} service(s)"
