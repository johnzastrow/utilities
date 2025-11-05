#!/bin/bash

#############################################################################
# Script Name: backup-directory.sh
# Description: Simple backup script for directories with compression
# Usage: ./backup-directory.sh <source_dir> [backup_dir]
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") <source_dir> [backup_dir]

Create a compressed backup of a directory.

ARGUMENTS:
    source_dir   Directory to backup (required)
    backup_dir   Destination directory (default: /tmp/backups)

OPTIONS:
    -h, --help   Show this help message

EXAMPLES:
    $(basename "$0") /etc
    $(basename "$0") /var/www /backups
    $(basename "$0") /home/user/docs /mnt/backup
EOF
    exit 0
}

# Parse help option
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# Check arguments
if [ -z "$1" ]; then
    echo -e "${RED}Error: Source directory is required${NC}"
    show_help
fi

SOURCE_DIR="$1"
BACKUP_DIR="${2:-/tmp/backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SOURCE_NAME=$(basename "$SOURCE_DIR")
BACKUP_FILE="${BACKUP_DIR}/${SOURCE_NAME}_${TIMESTAMP}.tar.gz"

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory does not exist: $SOURCE_DIR${NC}"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}Creating backup directory: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create backup directory${NC}"
        exit 1
    fi
fi

# Check if we have write permissions
if [ ! -w "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: No write permission for backup directory: $BACKUP_DIR${NC}"
    exit 1
fi

# Perform backup
echo -e "${YELLOW}Backing up: $SOURCE_DIR${NC}"
echo -e "${YELLOW}Destination: $BACKUP_FILE${NC}"
echo ""

tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>&1

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo ""
    echo -e "${GREEN}Backup completed successfully!${NC}"
    echo -e "Backup file: $BACKUP_FILE"
    echo -e "Backup size: $BACKUP_SIZE"
    
    # Calculate and display source directory size
    SOURCE_SIZE=$(du -sh "$SOURCE_DIR" | cut -f1)
    echo -e "Source size: $SOURCE_SIZE"
    
    # List recent backups
    echo ""
    echo "Recent backups in $BACKUP_DIR:"
    ls -lht "$BACKUP_DIR" | grep "${SOURCE_NAME}_" | head -5
    
    exit 0
else
    echo -e "${RED}Backup failed!${NC}"
    exit 1
fi
