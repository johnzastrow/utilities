#!/bin/bash

#############################################################################
# Script Name: system-info.sh
# Description: Display comprehensive system information
# Usage: ./system-info.sh
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

Display comprehensive system information.

OPTIONS:
    -h, --help      Show this help message
    -v, --version   Show version information

EXAMPLES:
    $(basename "$0")
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -v|--version)
            echo "system-info.sh v1.0"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
    shift
done

# System Information
print_header "SYSTEM INFORMATION"
echo "Hostname: $(hostname)"
echo "OS: $(uname -s)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Distribution: $NAME $VERSION"
fi

echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo ""

# CPU Information
print_header "CPU INFORMATION"
if [ -f /proc/cpuinfo ]; then
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    cpu_count=$(grep -c processor /proc/cpuinfo)
    echo "CPU Model: $cpu_model"
    echo "CPU Cores: $cpu_count"
fi
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

# Memory Information
print_header "MEMORY INFORMATION"
if command -v free &> /dev/null; then
    free -h
fi
echo ""

# Disk Information
print_header "DISK USAGE"
df -h | grep -E '^/dev|Filesystem'
echo ""

# Network Information
print_header "NETWORK INTERFACES"
if command -v ip &> /dev/null; then
    ip -brief addr show
elif command -v ifconfig &> /dev/null; then
    ifconfig | grep -E "^[a-z]|inet "
fi
echo ""

# Running Processes
print_header "TOP 5 PROCESSES BY CPU"
ps aux --sort=-%cpu | head -6
echo ""

print_header "TOP 5 PROCESSES BY MEMORY"
ps aux --sort=-%mem | head -6
echo ""

echo -e "${GREEN}System information gathered successfully!${NC}"
