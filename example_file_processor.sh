#!/usr/bin/env bash
#
# Script Name: example_file_processor.sh
# Description: Example script demonstrating how to use the bash template
# Author: Template User
# Version: 1.0.0
# Date: 2024-01-01
# License: MIT
#
# Usage: ./example_file_processor.sh [OPTIONS] <input_file>
#
# This example script processes a text file and demonstrates:
# - Using the template structure
# - Adding custom options
# - Input validation
# - Main logic implementation
#

###############################################################################
# Configuration and Global Variables
###############################################################################

# Exit immediately if a command exits with non-zero status
set -o errexit  # Same as set -e
# Treat unset variables as an error
set -o nounset  # Same as set -u
# Pipe failures cause script to exit
set -o pipefail
#
# Note: You can also use the compact form: set -euo pipefail
# The verbose form above is used for educational purposes

# Script metadata
SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME
SCRIPT_DIR=$(cd "$(dirname "${0}")" && pwd)
readonly SCRIPT_DIR
readonly SCRIPT_VERSION="1.0.0"

# Default values for options
VERBOSE=0
DEBUG=0
DRY_RUN=0
OUTPUT_FILE=""
INPUT_FILE=""
LINE_COUNT=10

# Color codes for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    RESET=''
fi

###############################################################################
# Utility Functions
###############################################################################

log_error() {
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $*" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${RESET} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $*"
}

log_debug() {
    if [[ "${DEBUG}" -eq 1 ]]; then
        echo -e "${MAGENTA}[DEBUG]${RESET} $*" >&2
    fi
}

log_verbose() {
    if [[ "${VERBOSE}" -eq 1 ]]; then
        echo -e "${CYAN}[VERBOSE]${RESET} $*"
    fi
}

usage() {
    cat << EOF
${BOLD}${SCRIPT_NAME}${RESET} - Example file processor using the bash template

${BOLD}USAGE:${RESET}
    ${SCRIPT_NAME} [OPTIONS] <input_file>

${BOLD}OPTIONS:${RESET}
    -h, --help              Show this help message and exit
    -v, --version           Show script version and exit
    -V, --verbose           Enable verbose output
    -d, --debug             Enable debug mode
    -n, --dry-run           Run in dry-run mode (no actual changes)
    -o, --output FILE       Specify output file (default: stdout)
    -c, --count NUM         Number of lines to process (default: 10)

${BOLD}ARGUMENTS:${RESET}
    input_file              The file to process (required)

${BOLD}EXAMPLES:${RESET}
    ${SCRIPT_NAME} input.txt
    ${SCRIPT_NAME} --verbose --count 20 input.txt
    ${SCRIPT_NAME} --dry-run --output result.txt input.txt

${BOLD}DESCRIPTION:${RESET}
    This example script reads a text file and displays the first N lines.
    It demonstrates how to customize the bash script template for your needs.

EOF
}

version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

cleanup() {
    local exit_code=$?
    log_debug "Cleanup function called with exit code: ${exit_code}"
    exit "${exit_code}"
}

trap cleanup EXIT
trap 'log_error "Script interrupted by user"; exit 130' INT TERM

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
    local missing_deps=()
    local required_commands=("cat" "wc" "head")
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "${cmd}"; then
            missing_deps+=("${cmd}")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 3
    fi
}

validate_input() {
    if [[ -z "${INPUT_FILE}" ]]; then
        log_error "Input file is required"
        return 1
    fi
    
    if [[ ! -f "${INPUT_FILE}" ]]; then
        log_error "Input file does not exist: ${INPUT_FILE}"
        return 1
    fi
    
    if [[ ! -r "${INPUT_FILE}" ]]; then
        log_error "Input file is not readable: ${INPUT_FILE}"
        return 1
    fi
    
    if [[ "${LINE_COUNT}" -lt 1 ]]; then
        log_error "Line count must be positive: ${LINE_COUNT}"
        return 1
    fi
    
    return 0
}

###############################################################################
# Argument Parsing
###############################################################################

parse_arguments() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi
    
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                version
                exit 0
                ;;
            -V|--verbose)
                VERBOSE=1
                log_verbose "Verbose mode enabled"
                shift
                ;;
            -d|--debug)
                DEBUG=1
                set -o xtrace
                log_debug "Debug mode enabled"
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=1
                log_info "Dry-run mode enabled"
                shift
                ;;
            -o|--output)
                if [[ -n "${2:-}" ]]; then
                    OUTPUT_FILE="${2}"
                    log_debug "Output file set to: ${OUTPUT_FILE}"
                    shift 2
                else
                    log_error "Option ${1} requires an argument"
                    exit 2
                fi
                ;;
            -c|--count)
                if [[ -n "${2:-}" ]]; then
                    LINE_COUNT="${2}"
                    log_debug "Line count set to: ${LINE_COUNT}"
                    shift 2
                else
                    log_error "Option ${1} requires an argument"
                    exit 2
                fi
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: ${1}"
                usage
                exit 2
                ;;
            *)
                # Store positional argument
                INPUT_FILE="${1}"
                log_debug "Input file: ${INPUT_FILE}"
                shift
                ;;
        esac
    done
}

###############################################################################
# Main Script Logic
###############################################################################

process_file() {
    local file="${1}"
    local count="${2}"
    
    log_verbose "Processing file: ${file}"
    
    # Get file info
    local total_lines
    total_lines=$(wc -l < "${file}")
    log_verbose "Total lines in file: ${total_lines}"
    
    # Process the file
    if [[ "${DRY_RUN}" -eq 1 ]]; then
        log_info "[DRY RUN] Would read ${count} lines from ${file}"
    else
        log_info "Reading first ${count} lines from ${file}:"
        echo "----------------------------------------"
        
        if [[ -n "${OUTPUT_FILE}" ]]; then
            head -n "${count}" "${file}" | tee "${OUTPUT_FILE}"
            log_success "Output written to: ${OUTPUT_FILE}"
        else
            head -n "${count}" "${file}"
        fi
        
        echo "----------------------------------------"
    fi
}

main() {
    log_info "Starting ${SCRIPT_NAME}..."
    log_debug "Script directory: ${SCRIPT_DIR}"
    
    # Check dependencies
    check_dependencies
    
    # Validate input
    if ! validate_input; then
        log_error "Input validation failed"
        exit 2
    fi
    
    # Process the file
    process_file "${INPUT_FILE}" "${LINE_COUNT}"
    
    log_success "Processing completed successfully!"
    return 0
}

###############################################################################
# Script Entry Point
###############################################################################

parse_arguments "$@"
main
exit 0
