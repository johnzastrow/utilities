# utilities

A place to store helper scripts and programs.

## Contents

### Bash Script Template

A comprehensive, production-ready bash script template that follows industry best practices.

- **File**: `bash_script_template.sh`
- **Documentation**: See `BASH_TEMPLATE_README.md` for detailed usage instructions
- **Example**: `example_file_processor.sh` demonstrates how to use the template

#### Quick Start

```bash
# Copy the template for your new script
cp bash_script_template.sh my_script.sh
chmod +x my_script.sh

# Edit my_script.sh and customize:
# - Script metadata (name, description, author)
# - Add your logic in the main() function
# - Add custom options in parse_arguments()
# - Define dependencies in check_dependencies()
```

#### Features

- ✅ Error handling with `set -euo pipefail`
- ✅ Comprehensive argument parsing
- ✅ Multiple log levels with color output
- ✅ Built-in help and version information
- ✅ Cleanup handlers and signal traps
- ✅ Dependency checking
- ✅ Input validation framework
- ✅ Dry-run mode support
- ✅ Well-documented and commented

For complete documentation, see [BASH_TEMPLATE_README.md](BASH_TEMPLATE_README.md).
A collection of mostly BASH scripts to assist with administering Linux boxen. Scraps I've found and keep.

## Overview

This repository contains useful BASH scripts for Linux system administration tasks. These are practical scripts collected and refined over time for common administrative needs.

## Scripts

### System Information
- **system-info.sh** - Display comprehensive system information
- **disk-usage-report.sh** - Generate disk usage reports with alerts
- **memory-check.sh** - Check memory usage and display details

### Backup & Maintenance
- **backup-directory.sh** - Simple backup script for directories
- **clean-old-logs.sh** - Clean up old log files
- **service-status.sh** - Check status of critical services

### Network Utilities
- **port-check.sh** - Check if ports are open/listening
- **network-info.sh** - Display network configuration details

### Log Monitoring
- **tail-logs.sh** - Tail multiple log files simultaneously
- **search-logs.sh** - Search through log files for patterns

### User Management
- **list-users.sh** - List system users with details
- **check-user-activity.sh** - Check recent user login activity

## Usage

All scripts include usage instructions. Run any script with `-h` or `--help` for details:

```bash
./scripts/system-info.sh --help
```

## Installation

1. Clone this repository:
```bash
git clone https://github.com/johnzastrow/utilities.git
cd utilities
```

2. Make scripts executable:
```bash
chmod +x scripts/*.sh
```

3. Optionally, add the scripts directory to your PATH:
```bash
export PATH=$PATH:$(pwd)/scripts
```

## License

See LICENSE file for details.
