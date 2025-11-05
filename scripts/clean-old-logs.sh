#!/bin/bash

#############################################################################
# Script Name: clean-old-logs.sh
# Description: Clean up old log files based on age
# Usage: ./clean-old-logs.sh [log_dir] [days]
#############################################################################

# Default values
DEFAULT_LOG_DIR="/var/log"
DEFAULT_DAYS=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") [log_dir] [days]

Clean up old log files based on age.

ARGUMENTS:
    log_dir    Directory containing logs (default: /var/log)
    days       Age in days for cleanup (default: 30)

OPTIONS:
    -h, --help    Show this help message
    -d, --dry-run Dry run - show what would be deleted

EXAMPLES:
    $(basename "$0")                    # Clean /var/log files older than 30 days
    $(basename "$0") /var/log 60        # Clean files older than 60 days
    $(basename "$0") -d                 # Dry run with defaults
    $(basename "$0") /var/log 7 -d      # Dry run for 7 days
EOF
    exit 0
}

# Parse arguments
DRY_RUN=false
LOG_DIR="$DEFAULT_LOG_DIR"
DAYS="$DEFAULT_DAYS"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            if [ -z "$LOG_DIR_SET" ]; then
                LOG_DIR="$1"
                LOG_DIR_SET=true
            elif [ -z "$DAYS_SET" ]; then
                DAYS="$1"
                DAYS_SET=true
            fi
            shift
            ;;
    esac
done

# Validate log directory
if [ ! -d "$LOG_DIR" ]; then
    echo -e "${RED}Error: Log directory does not exist: $LOG_DIR${NC}"
    exit 1
fi

# Validate days is a number
if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Days must be a positive number${NC}"
    exit 1
fi

echo "Clean Old Logs"
echo "========================================"
echo "Directory: $LOG_DIR"
echo "Age: Older than $DAYS days"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Mode: DRY RUN (no files will be deleted)${NC}"
else
    echo -e "${YELLOW}Mode: LIVE (files will be deleted)${NC}"
fi
echo ""

# Find old log files
echo "Searching for old log files..."
OLD_FILES=$(find "$LOG_DIR" -type f \( -name "*.log" -o -name "*.log.*" -o -name "*.gz" \) -mtime +$DAYS 2>/dev/null)

if [ -z "$OLD_FILES" ]; then
    echo -e "${GREEN}No old log files found.${NC}"
    exit 0
fi

# Count and calculate size
FILE_COUNT=$(echo "$OLD_FILES" | wc -l)
TOTAL_SIZE=$(echo "$OLD_FILES" | xargs du -ch 2>/dev/null | tail -1 | cut -f1)

echo "Found $FILE_COUNT old log file(s)"
echo "Total size: $TOTAL_SIZE"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "Files that would be deleted:"
    echo "$OLD_FILES" | while read -r file; do
        SIZE=$(du -h "$file" 2>/dev/null | cut -f1)
        echo "  [$SIZE] $file"
    done
    echo ""
    echo -e "${YELLOW}Dry run complete. No files were deleted.${NC}"
else
    echo "Deleting old log files..."
    DELETED=0
    FAILED=0
    
    echo "$OLD_FILES" | while read -r file; do
        if rm -f "$file" 2>/dev/null; then
            echo "  Deleted: $file"
            DELETED=$((DELETED + 1))
        else
            echo -e "  ${RED}Failed: $file${NC}"
            FAILED=$((FAILED + 1))
        fi
    done
    
    echo ""
    echo -e "${GREEN}Cleanup completed!${NC}"
    echo "Files deleted: $DELETED"
    if [ $FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $FAILED${NC}"
    fi
    echo "Space freed: $TOTAL_SIZE"
fi
