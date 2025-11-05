#!/bin/bash

#############################################################################
# Script Name: check-user-activity.sh
# Description: Check recent user login activity
# Usage: ./check-user-activity.sh [username]
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") [username]

Check recent user login activity and session information.

ARGUMENTS:
    username    Specific user to check (optional)
                If not provided, shows all recent activity

OPTIONS:
    -h, --help      Show this help message
    -c, --current   Show currently logged in users only
    -l, --last N    Show last N login attempts (default: 10)

EXAMPLES:
    $(basename "$0")              # Show all recent activity
    $(basename "$0") john         # Check activity for user 'john'
    $(basename "$0") -c           # Show currently logged in users
    $(basename "$0") -l 20        # Show last 20 logins
EOF
    exit 0
}

show_current_users() {
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}Currently Logged In Users${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    
    if command -v w &> /dev/null; then
        w
    elif command -v who &> /dev/null; then
        who
    else
        echo "No command available to show current users"
    fi
    echo ""
}

show_last_logins() {
    local username=$1
    local count=${2:-10}
    
    echo -e "${BLUE}=======================================${NC}"
    if [ -n "$username" ]; then
        echo -e "${BLUE}Last Logins: $username${NC}"
    else
        echo -e "${BLUE}Last $count Login Attempts${NC}"
    fi
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    
    if command -v last &> /dev/null; then
        if [ -n "$username" ]; then
            last "$username" -n "$count" 2>/dev/null
        else
            last -n "$count" 2>/dev/null
        fi
    else
        echo "Error: 'last' command not found"
    fi
    echo ""
}

show_failed_logins() {
    local username=$1
    
    echo -e "${BLUE}=======================================${NC}"
    if [ -n "$username" ]; then
        echo -e "${BLUE}Failed Login Attempts: $username${NC}"
    else
        echo -e "${BLUE}Recent Failed Login Attempts${NC}"
    fi
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    
    if command -v lastb &> /dev/null; then
        if [ -n "$username" ]; then
            lastb "$username" 2>/dev/null | head -20
        else
            lastb 2>/dev/null | head -20
        fi
    elif [ -f /var/log/auth.log ]; then
        echo "Checking auth.log for failed attempts..."
        if [ -n "$username" ]; then
            grep -i "failed" /var/log/auth.log | grep "$username" | tail -20
        else
            grep -i "failed" /var/log/auth.log | tail -20
        fi
    else
        echo "No failed login log available"
    fi
    echo ""
}

show_user_summary() {
    local username=$1
    
    if ! id "$username" &>/dev/null; then
        echo -e "${RED}Error: User '$username' not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}Activity Summary: $username${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    
    # Check if user is currently logged in
    if who | grep -q "^$username "; then
        echo -e "Status: ${GREEN}Currently logged in${NC}"
        echo ""
        echo "Active sessions:"
        who | grep "^$username " | sed 's/^/  /'
    else
        echo -e "Status: ${YELLOW}Not currently logged in${NC}"
    fi
    echo ""
    
    # Last login from lastlog
    if command -v lastlog &> /dev/null; then
        echo "Last login (from lastlog):"
        lastlog -u "$username" 2>/dev/null | tail -1
        echo ""
    fi
    
    # Recent activity
    show_last_logins "$username" 5
    
    # Failed attempts
    show_failed_logins "$username"
}

# Parse arguments
SHOW_CURRENT=false
COUNT=10
USERNAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -c|--current)
            SHOW_CURRENT=true
            shift
            ;;
        -l|--last)
            COUNT="$2"
            shift 2
            ;;
        *)
            USERNAME="$1"
            shift
            ;;
    esac
done

# Execute based on options
if [ "$SHOW_CURRENT" = true ]; then
    show_current_users
    exit 0
fi

if [ -n "$USERNAME" ]; then
    show_user_summary "$USERNAME"
else
    show_current_users
    show_last_logins "" "$COUNT"
    show_failed_logins ""
fi
