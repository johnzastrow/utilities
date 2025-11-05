# Bash Script Template

A comprehensive, production-ready bash script template that follows industry best practices. This template provides a robust foundation for creating reliable and maintainable bash scripts.

## Features

✅ **Error Handling**: Built-in error handling with `set -euo pipefail`  
✅ **Argument Parsing**: Flexible command-line option parsing  
✅ **Logging**: Multiple log levels (ERROR, WARNING, INFO, SUCCESS, DEBUG, VERBOSE)  
✅ **Color Output**: Automatic color support detection for terminals  
✅ **Help & Version**: Built-in help and version information  
✅ **Cleanup Handling**: Automatic cleanup on script exit  
✅ **Dependency Checking**: Verify required commands are available  
✅ **Input Validation**: Framework for validating user inputs  
✅ **Dry-Run Mode**: Test scripts without making actual changes  
✅ **Well-Documented**: Comprehensive comments explaining each section  

## Quick Start

1. **Copy the template:**
   ```bash
   cp bash_script_template.sh my_script.sh
   chmod +x my_script.sh
   ```

2. **Customize the metadata:**
   - Update script name, description, author
   - Modify version number
   - Update usage examples

3. **Add your logic:**
   - Place your code in the `main()` function
   - Add custom options in `parse_arguments()`
   - Define required dependencies in `check_dependencies()`

## Usage Examples

### Show Help
```bash
./bash_script_template.sh --help
```

### Show Version
```bash
./bash_script_template.sh --version
```

### Enable Verbose Output
```bash
./bash_script_template.sh --verbose
```

### Debug Mode
```bash
./bash_script_template.sh --debug
```

### Dry-Run Mode
```bash
./bash_script_template.sh --dry-run
```

### Specify Output File
```bash
./bash_script_template.sh --output results.txt
```

### Quiet Mode
```bash
./bash_script_template.sh --quiet
```

### Combine Multiple Options
```bash
./bash_script_template.sh --verbose --dry-run --output /tmp/test.txt
```

## Template Structure

### 1. Script Header
Contains metadata, license information, and usage documentation.

### 2. Configuration Section
- Script metadata (name, version, directory)
- Global variables
- Default option values
- Color code definitions

### 3. Utility Functions
- `log_error()` - Print error messages in red
- `log_warning()` - Print warnings in yellow
- `log_info()` - Print informational messages in blue
- `log_success()` - Print success messages in green
- `log_debug()` - Print debug messages (when debug mode enabled)
- `log_verbose()` - Print verbose messages (when verbose mode enabled)
- `usage()` - Display help information
- `version()` - Display version information
- `cleanup()` - Handle cleanup on exit
- `command_exists()` - Check if a command is available
- `check_dependencies()` - Verify required dependencies
- `validate_input()` - Validate user inputs
- `confirm()` - Prompt user for confirmation

### 4. Argument Parsing
Robust argument parsing supporting:
- Short options (`-h`, `-v`)
- Long options (`--help`, `--version`)
- Options with values (`-o file`, `--output file`)
- Positional arguments
- Double-dash separator (`--`)

### 5. Main Script Logic
The `main()` function contains your primary script logic.

## Customization Guide

### Adding New Options

1. **Add a global variable** (in Configuration section):
   ```bash
   MY_OPTION=""
   ```

2. **Add parsing logic** (in `parse_arguments()` function):
   ```bash
   -m|--my-option)
       if [[ -n "${2:-}" ]]; then
           MY_OPTION="${2}"
           shift 2
       else
           log_error "Option ${1} requires an argument"
           exit 2
       fi
       ;;
   ```

3. **Update usage** (in `usage()` function):
   ```bash
   -m, --my-option VALUE   Description of my option
   ```

### Adding Dependencies

Add required commands to the `check_dependencies()` function:

```bash
local required_commands=(
    "curl"
    "jq"
    "git"
)
```

### Adding Custom Validation

Implement your validation logic in the `validate_input()` function:

```bash
validate_input() {
    if [[ -z "${REQUIRED_VAR}" ]]; then
        log_error "REQUIRED_VAR must be set"
        return 1
    fi
    
    if [[ ! -d "${SOME_DIR}" ]]; then
        log_error "Directory does not exist: ${SOME_DIR}"
        return 1
    fi
    
    return 0
}
```

### Adding Cleanup Tasks

Add cleanup logic in the `cleanup()` function:

```bash
cleanup() {
    local exit_code=$?
    
    # Remove temporary files
    rm -f "${TEMP_FILE}"
    
    # Kill background processes
    [[ -n "${BG_PID:-}" ]] && kill "${BG_PID}" 2>/dev/null
    
    exit "${exit_code}"
}
```

## Best Practices Implemented

### Error Handling
- `set -o errexit` - Exit on command failure
- `set -o nounset` - Exit on undefined variable
- `set -o pipefail` - Catch failures in pipes
- Trap handlers for cleanup and interruption

### Code Style
- Readonly variables where appropriate
- Local variables in functions
- Quoted variable expansions
- Consistent naming conventions
- Comprehensive comments

### User Experience
- Clear help documentation
- Colored output (when terminal supports it)
- Informative error messages
- Debug and verbose modes
- Dry-run capability

### Robustness
- Dependency checking
- Input validation
- Graceful error handling
- Cleanup on exit
- Signal handling

## Exit Codes

The template uses standard exit codes:

- `0` - Success
- `1` - General error
- `2` - Invalid arguments
- `3` - Missing dependencies
- `10` - Configuration error
- `130` - Script interrupted by user (Ctrl+C)

Add custom exit codes as needed for your script.

## Testing Your Script

1. **Test all options:**
   ```bash
   ./my_script.sh --help
   ./my_script.sh --version
   ./my_script.sh --verbose
   ./my_script.sh --debug
   ```

2. **Test error handling:**
   ```bash
   ./my_script.sh --invalid-option
   ./my_script.sh --output  # Missing argument
   ```

3. **Test with ShellCheck:**
   ```bash
   shellcheck my_script.sh
   ```

4. **Test in dry-run mode:**
   ```bash
   ./my_script.sh --dry-run
   ```

## Tips

- Use `readonly` for constants that shouldn't change
- Use `local` for function-scoped variables
- Always quote variable expansions: `"${var}"`
- Use `[[ ]]` instead of `[ ]` for tests
- Prefer `$()` over backticks for command substitution
- Check ShellCheck warnings and errors
- Test with `bash -n script.sh` to check syntax

## License

This template is provided under the MIT License. Feel free to use and modify for your projects.

## Contributing

Improvements and suggestions are welcome! Common enhancements include:
- Additional utility functions
- More sophisticated argument parsing
- Configuration file support
- Additional logging options
- Progress bars
- Email notifications

## Resources

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck - Shell script analysis tool](https://www.shellcheck.net/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
