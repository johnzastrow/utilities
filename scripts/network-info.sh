#!/bin/bash

#############################################################################
# Script Name: network-info.sh
# Description: Display network configuration details
# Usage: ./network-info.sh
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}===================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================${NC}"
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Display network configuration and connectivity information.

OPTIONS:
    -h, --help      Show this help message
    -s, --simple    Show simplified output

EXAMPLES:
    $(basename "$0")           # Show detailed network info
    $(basename "$0") -s        # Show simple summary
EOF
    exit 0
}

show_simple() {
    echo -e "${BLUE}Network Summary:${NC}"
    echo ""
    if command -v ip &> /dev/null; then
        ip -brief addr show
    elif command -v ifconfig &> /dev/null; then
        ifconfig | grep -E "^[a-z]|inet " | head -20
    fi
}

show_detailed() {
    # Hostname
    print_header "HOSTNAME"
    echo "Hostname: $(hostname)"
    echo "FQDN: $(hostname -f 2>/dev/null || hostname)"
    echo ""
    
    # Network Interfaces
    print_header "NETWORK INTERFACES"
    if command -v ip &> /dev/null; then
        ip addr show
    elif command -v ifconfig &> /dev/null; then
        ifconfig
    else
        echo "No network interface command found"
    fi
    echo ""
    
    # Routing Table
    print_header "ROUTING TABLE"
    if command -v ip &> /dev/null; then
        ip route show
    elif command -v route &> /dev/null; then
        route -n
    else
        echo "No routing command found"
    fi
    echo ""
    
    # DNS Configuration
    print_header "DNS CONFIGURATION"
    if [ -f /etc/resolv.conf ]; then
        echo "Nameservers:"
        grep "^nameserver" /etc/resolv.conf | awk '{print "  " $2}'
        echo ""
        echo "Search domains:"
        grep "^search" /etc/resolv.conf | cut -d' ' -f2- | sed 's/^/  /'
    else
        echo "No /etc/resolv.conf found"
    fi
    echo ""
    
    # Default Gateway
    print_header "DEFAULT GATEWAY"
    if command -v ip &> /dev/null; then
        GATEWAY=$(ip route show default | awk '/default/ {print $3}')
        if [ -n "$GATEWAY" ]; then
            echo "Gateway: $GATEWAY"
            # Try to ping gateway
            if command -v ping &> /dev/null; then
                if ping -c 1 -W 2 "$GATEWAY" &> /dev/null; then
                    echo -e "Status: ${GREEN}Reachable${NC}"
                else
                    echo -e "Status: ${RED}Not reachable${NC}"
                fi
            fi
        else
            echo "No default gateway configured"
        fi
    fi
    echo ""
    
    # Active Connections
    print_header "ACTIVE CONNECTIONS (Sample)"
    if command -v ss &> /dev/null; then
        echo "Established TCP connections:"
        ss -tn state established 2>/dev/null | head -10
    elif command -v netstat &> /dev/null; then
        echo "Established TCP connections:"
        netstat -tn | grep ESTABLISHED | head -10
    fi
    echo ""
    
    # Internet Connectivity Test
    print_header "INTERNET CONNECTIVITY"
    if command -v ping &> /dev/null; then
        echo "Testing connectivity to 8.8.8.8..."
        if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
            echo -e "Result: ${GREEN}Connected${NC}"
        else
            echo -e "Result: ${RED}Not connected${NC}"
        fi
    else
        echo "Ping command not available"
    fi
}

# Parse arguments
case "$1" in
    -h|--help)
        show_help
        ;;
    -s|--simple)
        show_simple
        ;;
    *)
        show_detailed
        ;;
esac
