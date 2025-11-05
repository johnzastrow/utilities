#!/bin/bash

#############################################################################
# Script Name: list-users.sh
# Description: List system users with details
# Usage: ./list-users.sh
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

List system users with details.

OPTIONS:
    -h, --help      Show this help message
    -a, --all       Show all users including system users
    -r, --real      Show only real users (default)
    -s, --system    Show only system users

EXAMPLES:
    $(basename "$0")           # Show real users only
    $(basename "$0") -a        # Show all users
    $(basename "$0") -s        # Show system users only
EOF
    exit 0
}

list_users() {
    local mode=$1
    local min_uid=1000
    local max_uid=60000
    
    echo -e "${BLUE}=======================================${NC}"
    case $mode in
        all)
            echo -e "${BLUE}All Users${NC}"
            min_uid=0
            max_uid=65535
            ;;
        system)
            echo -e "${BLUE}System Users${NC}"
            min_uid=0
            max_uid=999
            ;;
        *)
            echo -e "${BLUE}Real Users${NC}"
            ;;
    esac
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    
    printf "%-15s %-6s %-6s %-25s %-s\n" "USERNAME" "UID" "GID" "HOME" "SHELL"
    echo "--------------------------------------------------------------------------------"
    
    # Read /etc/passwd and filter users
    while IFS=: read -r username _ uid gid _ home shell; do
        if [ "$uid" -ge "$min_uid" ] && [ "$uid" -le "$max_uid" ]; then
            printf "%-15s %-6s %-6s %-25s %-s\n" "$username" "$uid" "$gid" "$home" "$shell"
        fi
    done < /etc/passwd
    
    echo ""
    
    # Count users
    local count=$(awk -F: -v min="$min_uid" -v max="$max_uid" '$3 >= min && $3 <= max {count++} END {print count}' /etc/passwd)
    echo "Total users: $count"
}

show_user_details() {
    local username=$1
    
    if ! id "$username" &>/dev/null; then
        echo -e "${RED}Error: User '$username' not found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${BLUE}User Details: $username${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    
    # Get user info
    local user_info=$(getent passwd "$username")
    local uid=$(echo "$user_info" | cut -d: -f3)
    local gid=$(echo "$user_info" | cut -d: -f4)
    local gecos=$(echo "$user_info" | cut -d: -f5)
    local home=$(echo "$user_info" | cut -d: -f6)
    local shell=$(echo "$user_info" | cut -d: -f7)
    
    echo "Username: $username"
    echo "UID: $uid"
    echo "GID: $gid"
    echo "Full Name: ${gecos:-N/A}"
    echo "Home Directory: $home"
    echo "Shell: $shell"
    echo ""
    
    # Groups
    echo "Groups:"
    groups "$username" | sed 's/^[^:]*: //' | tr ' ' '\n' | sed 's/^/  /'
    echo ""
    
    # Last login
    echo "Last Login:"
    lastlog -u "$username" 2>/dev/null | tail -1 | awk '{$1=""; print}'
    echo ""
    
    # Check if home directory exists
    if [ -d "$home" ]; then
        echo -e "Home Directory: ${GREEN}Exists${NC}"
        if [ -r "$home" ]; then
            du -sh "$home" 2>/dev/null | awk '{print "Size: " $1}'
        fi
    else
        echo -e "Home Directory: ${RED}Does not exist${NC}"
    fi
}

# Parse arguments
MODE="real"

case "$1" in
    -h|--help)
        show_help
        ;;
    -a|--all)
        MODE="all"
        ;;
    -s|--system)
        MODE="system"
        ;;
    -r|--real)
        MODE="real"
        ;;
    "")
        MODE="real"
        ;;
    *)
        # If argument is not a flag, treat it as a username
        show_user_details "$1"
        exit $?
        ;;
esac

list_users "$MODE"
