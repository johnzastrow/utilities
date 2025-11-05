#!/bin/bash

#############################################################################
# Script Name: tail-logs.sh
# Description: Tail multiple log files simultaneously
# Usage: ./tail-logs.sh [logfile1] [logfile2] ...
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Common log files
DEFAULT_LOGS=(
    "/var/log/syslog"
    "/var/log/messages"
    "/var/log/auth.log"
)

show_help() {
    cat << EOF
Usage: $(basename "$0") [logfiles...]

Tail multiple log files simultaneously with colored output.

ARGUMENTS:
    logfiles    List of log files to tail (optional)
                If not provided, tails common system logs

OPTIONS:
    -h, --help  Show this help message
    -n NUM      Number of lines to show (default: 10)

EXAMPLES:
    $(basename "$0")                           # Tail default system logs
    $(basename "$0") /var/log/nginx/error.log  # Tail specific log
    $(basename "$0") -n 20 /var/log/syslog     # Show 20 lines
EOF
    exit 0
}

# Parse arguments
LINES=10
LOG_FILES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -n)
            LINES="$2"
            shift 2
            ;;
        *)
            LOG_FILES+=("$1")
            shift
            ;;
    esac
done

# Use default logs if none specified
if [ ${#LOG_FILES[@]} -eq 0 ]; then
    for log in "${DEFAULT_LOGS[@]}"; do
        if [ -f "$log" ]; then
            LOG_FILES+=("$log")
        fi
    done
fi

# Check if any log files were found
if [ ${#LOG_FILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No log files found or specified${NC}"
    echo ""
    echo "Tried default locations:"
    for log in "${DEFAULT_LOGS[@]}"; do
        echo "  $log"
    done
    exit 1
fi

# Verify log files exist and are readable
VALID_LOGS=()
for log in "${LOG_FILES[@]}"; do
    if [ ! -f "$log" ]; then
        echo -e "${YELLOW}Warning: Log file does not exist: $log${NC}"
    elif [ ! -r "$log" ]; then
        echo -e "${YELLOW}Warning: Cannot read log file: $log${NC}"
    else
        VALID_LOGS+=("$log")
    fi
done

if [ ${#VALID_LOGS[@]} -eq 0 ]; then
    echo -e "${RED}Error: No valid log files to tail${NC}"
    exit 1
fi

# Display header
echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}Tailing Log Files${NC}"
echo -e "${BLUE}=======================================${NC}"
for log in "${VALID_LOGS[@]}"; do
    echo -e "${CYAN}  - $log${NC}"
done
echo -e "${BLUE}=======================================${NC}"
echo ""

# Tail the logs
if command -v multitail &> /dev/null; then
    # Use multitail if available (better for multiple files)
    multitail "${VALID_LOGS[@]}"
else
    # Fall back to tail -f with label
    # Note: Using stdbuf for unbuffered output to ensure colored filtering works in real-time
    if command -v stdbuf &> /dev/null; then
        stdbuf -oL tail -n "$LINES" -f "${VALID_LOGS[@]}" 2>&1 | while IFS= read -r line; do
            # Add timestamp and color
            if [[ "$line" == "==>"* ]]; then
                # File header from tail
                echo -e "${GREEN}${line}${NC}"
            elif [[ "$line" == *"error"* ]] || [[ "$line" == *"ERROR"* ]] || [[ "$line" == *"Error"* ]]; then
                echo -e "${RED}${line}${NC}"
            elif [[ "$line" == *"warning"* ]] || [[ "$line" == *"WARNING"* ]] || [[ "$line" == *"Warning"* ]]; then
                echo -e "${YELLOW}${line}${NC}"
            else
                echo "$line"
            fi
        done
    else
        # Without stdbuf, output may be buffered
        tail -n "$LINES" -f "${VALID_LOGS[@]}" 2>&1 | while IFS= read -r line; do
            # Add timestamp and color
            if [[ "$line" == "==>"* ]]; then
                # File header from tail
                echo -e "${GREEN}${line}${NC}"
            elif [[ "$line" == *"error"* ]] || [[ "$line" == *"ERROR"* ]] || [[ "$line" == *"Error"* ]]; then
                echo -e "${RED}${line}${NC}"
            elif [[ "$line" == *"warning"* ]] || [[ "$line" == *"WARNING"* ]] || [[ "$line" == *"Warning"* ]]; then
                echo -e "${YELLOW}${line}${NC}"
            else
                echo "$line"
            fi
        done
    fi
fi
