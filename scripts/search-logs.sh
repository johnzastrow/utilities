#!/bin/bash

#############################################################################
# Script Name: search-logs.sh
# Description: Search through log files for patterns
# Usage: ./search-logs.sh <pattern> [logfile]
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Common log locations
DEFAULT_LOG_DIRS=(
    "/var/log"
)

show_help() {
    cat << EOF
Usage: $(basename "$0") <pattern> [logfile]

Search through log files for specific patterns.

ARGUMENTS:
    pattern     Search pattern (required)
    logfile     Specific log file to search (optional)
                If not provided, searches common log locations

OPTIONS:
    -h, --help      Show this help message
    -i, --ignore-case  Case-insensitive search
    -c, --context N    Show N lines of context
    -t, --today        Search only today's logs
    -e, --errors       Search for common error patterns

EXAMPLES:
    $(basename "$0") "error"                    # Search for "error" in default logs
    $(basename "$0") -i "failed" /var/log/auth.log  # Case-insensitive search
    $(basename "$0") -c 3 "connection"          # Show 3 lines of context
    $(basename "$0") -e                         # Search for common errors
EOF
    exit 0
}

# Parse arguments
IGNORE_CASE=""
CONTEXT=""
TODAY_ONLY=false
ERRORS_ONLY=false
PATTERN=""
LOGFILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -i|--ignore-case)
            IGNORE_CASE="-i"
            shift
            ;;
        -c|--context)
            CONTEXT="-C $2"
            shift 2
            ;;
        -t|--today)
            TODAY_ONLY=true
            shift
            ;;
        -e|--errors)
            ERRORS_ONLY=true
            shift
            ;;
        *)
            if [ -z "$PATTERN" ]; then
                PATTERN="$1"
            elif [ -z "$LOGFILE" ]; then
                LOGFILE="$1"
            fi
            shift
            ;;
    esac
done

# Set error patterns if requested
if [ "$ERRORS_ONLY" = true ]; then
    PATTERN="error|Error|ERROR|fail|Fail|FAIL|critical|Critical|CRITICAL|panic"
    IGNORE_CASE="-i"
fi

# Validate pattern
if [ -z "$PATTERN" ]; then
    echo -e "${RED}Error: Search pattern is required${NC}"
    show_help
fi

# Determine which files to search
if [ -n "$LOGFILE" ]; then
    if [ ! -f "$LOGFILE" ]; then
        echo -e "${RED}Error: Log file not found: $LOGFILE${NC}"
        exit 1
    fi
    if [ ! -r "$LOGFILE" ]; then
        echo -e "${RED}Error: Cannot read log file: $LOGFILE${NC}"
        exit 1
    fi
    SEARCH_FILES=("$LOGFILE")
else
    # Find log files in default locations
    SEARCH_FILES=()
    for dir in "${DEFAULT_LOG_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' file; do
                SEARCH_FILES+=("$file")
            done < <(find "$dir" -type f \( -name "*.log" -o -name "syslog" -o -name "messages" \) -readable -print0 2>/dev/null)
        fi
    done
fi

if [ ${#SEARCH_FILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No log files found to search${NC}"
    exit 1
fi

# Display search info
echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}Searching Log Files${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "Pattern: ${CYAN}$PATTERN${NC}"
echo -e "Files: ${#SEARCH_FILES[@]}"
if [ "$TODAY_ONLY" = true ]; then
    echo -e "Filter: Today's entries only"
fi
echo -e "${BLUE}=======================================${NC}"
echo ""

# Perform search
TOTAL_MATCHES=0

for logfile in "${SEARCH_FILES[@]}"; do
    if [ "$TODAY_ONLY" = true ]; then
        TODAY=$(date +"%b %d")
        MATCHES=$(grep $IGNORE_CASE $CONTEXT "$TODAY" "$logfile" 2>/dev/null | grep -E $IGNORE_CASE $CONTEXT "$PATTERN" 2>/dev/null)
    else
        MATCHES=$(grep -E $IGNORE_CASE $CONTEXT "$PATTERN" "$logfile" 2>/dev/null)
    fi
    
    if [ -n "$MATCHES" ]; then
        MATCH_COUNT=$(echo "$MATCHES" | wc -l)
        TOTAL_MATCHES=$((TOTAL_MATCHES + MATCH_COUNT))
        
        echo -e "${GREEN}==> $logfile${NC} ${YELLOW}($MATCH_COUNT matches)${NC}"
        echo "$MATCHES" | while IFS= read -r line; do
            # Highlight the pattern in the output
            echo "$line" | GREP_COLOR='01;31' grep -E --color=always $IGNORE_CASE "$PATTERN|$"
        done
        echo ""
    fi
done

# Summary
echo -e "${BLUE}=======================================${NC}"
if [ $TOTAL_MATCHES -eq 0 ]; then
    echo -e "${YELLOW}No matches found${NC}"
else
    echo -e "${GREEN}Total matches: $TOTAL_MATCHES${NC}"
fi
echo -e "${BLUE}=======================================${NC}"
