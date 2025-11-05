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
