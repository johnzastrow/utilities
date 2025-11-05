#!/usr/bin/env bash
#
# Script Name: bash_script_template.sh
# Description: A comprehensive bash script template following best practices
# Author: Your Name
# Version: 1.0.0
# Date: $(date +%Y-%m-%d)
# License: MIT
#
# Usage: ./bash_script_template.sh [OPTIONS] [ARGUMENTS]
#
# This template provides a robust foundation for bash scripts with:
# - Proper error handling
# - Argument parsing
# - Logging functionality
# - Help/usage documentation
# - Cleanup on exit
# - Color output support
# - Input validation
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
# Enable debug mode (uncomment to trace execution)
# set -o xtrace  # Same as set -x
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
QUIET=0
OUTPUT_FILE=""

# Color codes for output (will be disabled if not a terminal)
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

# Print colored messages to stderr
log_error() {
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $*" >&2
}

log_info() {
    if [[ "${QUIET}" -eq 0 ]]; then
        echo -e "${BLUE}[INFO]${RESET} $*"
    fi
}

log_success() {
    if [[ "${QUIET}" -eq 0 ]]; then
        echo -e "${GREEN}[SUCCESS]${RESET} $*"
    fi
}

log_debug() {
    if [[ "${DEBUG}" -eq 1 && "${QUIET}" -eq 0 ]]; then
        echo -e "${MAGENTA}[DEBUG]${RESET} $*" >&2
    fi
}

log_verbose() {
    if [[ "${VERBOSE}" -eq 1 && "${QUIET}" -eq 0 ]]; then
        echo -e "${CYAN}[VERBOSE]${RESET} $*"
    fi
}

# Display usage information
usage() {
    cat << EOF
${BOLD}${SCRIPT_NAME}${RESET} - A comprehensive bash script template

${BOLD}USAGE:${RESET}
    ${SCRIPT_NAME} [OPTIONS] [ARGUMENTS]

${BOLD}OPTIONS:${RESET}
    -h, --help              Show this help message and exit
    -v, --version           Show script version and exit
    -V, --verbose           Enable verbose output
    -d, --debug             Enable debug mode
    -n, --dry-run           Run in dry-run mode (no actual changes)
    -o, --output FILE       Specify output file
    -q, --quiet             Suppress non-error output

${BOLD}ARGUMENTS:${RESET}
    Add your script-specific arguments here

${BOLD}EXAMPLES:${RESET}
    ${SCRIPT_NAME} --verbose
    ${SCRIPT_NAME} --dry-run --output result.txt
    ${SCRIPT_NAME} -d -v

${BOLD}DESCRIPTION:${RESET}
    This is a template bash script demonstrating best practices.
    Customize this section with your script's specific functionality.

${BOLD}EXIT CODES:${RESET}
    0   Success
    1   General error
    2   Invalid arguments
    3   Missing dependencies
    10  Configuration error

EOF
}

# Display version information
version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

# Cleanup function - called on script exit
cleanup() {
    local exit_code=$?
    log_debug "Cleanup function called with exit code: ${exit_code}"
    
    # Add cleanup tasks here
    # - Remove temporary files
    # - Restore system state
    # - Close file descriptors
    # - Kill background processes
    
    # Example: rm -f "${TEMP_FILE}"
    
    exit "${exit_code}"
}

# Trap errors and cleanup on exit
trap cleanup EXIT
trap 'log_error "Script interrupted by user"; exit 130' INT TERM

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()
    
    # Add your required commands here
    local required_commands=(
        # "curl"
        # "jq"
        # "git"
    )
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "${cmd}"; then
            missing_deps+=("${cmd}")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again"
        exit 3
    fi
}

# Validate input parameters
validate_input() {
    # Add your validation logic here
    # Example:
    # if [[ -n "${OUTPUT_FILE}" && -e "${OUTPUT_FILE}" ]]; then
    #     log_error "Output file already exists: ${OUTPUT_FILE}"
    #     return 1
    # fi
    
    return 0
}

# Prompt user for confirmation
confirm() {
    local prompt="${1:-Are you sure?}"
    local response
    
    read -r -p "${prompt} [y/N] " response
    case "${response}" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

###############################################################################
# Argument Parsing
###############################################################################

parse_arguments() {
    # If no arguments provided, show usage
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
                set -o xtrace  # Enable trace mode
                log_debug "Debug mode enabled"
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=1
                log_info "Dry-run mode enabled (no changes will be made)"
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
            -q|--quiet)
                QUIET=1
                # Note: --quiet suppresses info/success/verbose/debug output
                # but errors and warnings are still shown
                shift
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
                # Handle positional arguments
                log_debug "Positional argument: ${1}"
                # Store positional arguments in an array if needed
                # POSITIONAL_ARGS+=("${1}")
                shift
                ;;
        esac
    done
}

###############################################################################
# Main Script Logic
###############################################################################

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
    
    # Add your main script logic here
    # -------------------------------------
    
    log_verbose "Processing main logic..."
    
    # Example: Check if running in dry-run mode
    if [[ "${DRY_RUN}" -eq 1 ]]; then
        log_info "[DRY RUN] Would execute main functionality here"
    else
        # Actual implementation
        log_info "Executing main functionality..."
        
        # Your code here
        
    fi
    
    # -------------------------------------
    
    log_success "Script completed successfully!"
    return 0
}

###############################################################################
# Script Entry Point
###############################################################################

# Parse command line arguments
parse_arguments "$@"

# Run main function
main

# Exit with success
exit 0
