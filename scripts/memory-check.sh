#!/bin/bash

#############################################################################
# Script Name: memory-check.sh
# Description: Check memory usage and display detailed information
# Usage: ./memory-check.sh
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

Check memory usage and display detailed information.

OPTIONS:
    -h, --help      Show this help message
    -s, --simple    Show simplified output
    -w, --watch     Watch mode (update every 2 seconds)

EXAMPLES:
    $(basename "$0")           # Show detailed memory info
    $(basename "$0") -s        # Show simple summary
    $(basename "$0") -w        # Watch memory usage
EOF
    exit 0
}

show_simple() {
    if command -v free &> /dev/null; then
        echo -e "${BLUE}Memory Usage Summary:${NC}"
        free -h
    else
        echo "Error: free command not found"
        exit 1
    fi
}

show_detailed() {
    echo -e "${BLUE}===================================${NC}"
    echo -e "${BLUE}MEMORY USAGE DETAILS${NC}"
    echo -e "${BLUE}===================================${NC}"
    echo ""
    
    if command -v free &> /dev/null; then
        free -h
        echo ""
        
        # Calculate memory usage percentage
        mem_info=$(free | grep Mem)
        total=$(echo $mem_info | awk '{print $2}')
        used=$(echo $mem_info | awk '{print $3}')
        available=$(echo $mem_info | awk '{print $7}')
        
        if [ -n "$total" ] && [ "$total" -gt 0 ]; then
            usage_percent=$((used * 100 / total))
            available_percent=$((available * 100 / total))
            
            echo -e "Memory Usage: ${usage_percent}%"
            echo -e "Available Memory: ${available_percent}%"
            echo ""
            
            # Alert if memory usage is high
            if [ "$usage_percent" -ge 90 ]; then
                echo -e "${RED}WARNING: Memory usage is critical (${usage_percent}%)${NC}"
            elif [ "$usage_percent" -ge 75 ]; then
                echo -e "${YELLOW}CAUTION: Memory usage is high (${usage_percent}%)${NC}"
            else
                echo -e "${GREEN}Memory usage is normal (${usage_percent}%)${NC}"
            fi
        fi
    else
        echo "Error: free command not found"
        exit 1
    fi
    
    echo ""
    echo -e "${BLUE}SWAP USAGE:${NC}"
    if command -v swapon &> /dev/null; then
        swapon --show 2>/dev/null || echo "No swap space configured"
    fi
    
    echo ""
    echo -e "${BLUE}TOP 10 MEMORY CONSUMING PROCESSES:${NC}"
    ps aux --sort=-%mem | head -11 | awk 'NR==1 {print $0} NR>1 {printf "%-10s %5s %5s %10s  %s\n", $1, $2, $4, $6, $11}'
}

watch_mode() {
    echo "Watching memory usage (Ctrl+C to exit)..."
    echo ""
    while true; do
        clear
        show_detailed
        sleep 2
    done
}

# Parse arguments
case "$1" in
    -h|--help)
        show_help
        ;;
    -s|--simple)
        show_simple
        ;;
    -w|--watch)
        watch_mode
        ;;
    "")
        show_detailed
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        ;;
esac
