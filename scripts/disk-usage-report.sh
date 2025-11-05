#!/bin/bash

#############################################################################
# Script Name: disk-usage-report.sh
# Description: Generate disk usage reports with alerts for high usage
# Usage: ./disk-usage-report.sh [threshold]
#############################################################################

# Default threshold for warning (percentage)
THRESHOLD=${1:-80}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") [THRESHOLD]

Generate disk usage reports and alert on high usage.

ARGUMENTS:
    THRESHOLD    Alert threshold percentage (default: 80)

OPTIONS:
    -h, --help   Show this help message

EXAMPLES:
    $(basename "$0")           # Use default 80% threshold
    $(basename "$0") 90        # Use 90% threshold
EOF
    exit 0
}

# Parse arguments
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

echo "Disk Usage Report"
echo "Alert Threshold: ${THRESHOLD}%"
echo "========================================"
echo ""

# Check if df command is available
if ! command -v df &> /dev/null; then
    echo "Error: df command not found"
    exit 1
fi

# Get disk usage and check against threshold
df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk -v threshold="$THRESHOLD" -v red="$RED" -v green="$GREEN" -v yellow="$YELLOW" -v nc="$NC" '
{
    # Extract usage percentage (remove % sign)
    usage = $5
    gsub(/%/, "", usage)
    
    # Print with color based on usage
    if (usage >= threshold) {
        printf red "%-20s %8s %8s %8s %5s%% %s [HIGH USAGE!]\n" nc, $1, $2, $3, $4, usage, $6
    } else if (usage >= threshold - 10) {
        printf yellow "%-20s %8s %8s %8s %5s%% %s [WARNING]\n" nc, $1, $2, $3, $4, usage, $6
    } else {
        printf green "%-20s %8s %8s %8s %5s%% %s [OK]\n" nc, $1, $2, $3, $4, usage, $6
    }
}'

echo ""
echo "Legend:"
echo -e "${GREEN}[OK]${NC} - Usage below threshold"
echo -e "${YELLOW}[WARNING]${NC} - Usage within 10% of threshold"
echo -e "${RED}[HIGH USAGE!]${NC} - Usage at or above threshold"
echo ""

# Check for any critical usage
CRITICAL=$(df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk -v threshold="$THRESHOLD" '{gsub(/%/, "", $5); if ($5 >= threshold) print $0}')

if [ -n "$CRITICAL" ]; then
    echo -e "${RED}Action required: Some filesystems are at or above ${THRESHOLD}% usage!${NC}"
    exit 1
else
    echo -e "${GREEN}All filesystems are within acceptable usage limits.${NC}"
    exit 0
fi
