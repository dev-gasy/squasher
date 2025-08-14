# Git Commit Squasher

A bash script to squash multiple git commits into a single commit.

## Installation

### Quick Install (Recommended)

```bash
# Download and install globally
sudo curl -o /usr/local/bin/squasher https://raw.githubusercontent.com/dev-gasy/squasher/main/squasher.sh
sudo chmod +x /usr/local/bin/squasher

# Verify installation
squasher --help
```

### Alternative Installation (if sudo not available)

```bash
# Install to user directory
mkdir -p ~/.local/bin
curl -o ~/.local/bin/squasher https://raw.githubusercontent.com/dev-gasy/squasher/main/squasher.sh
chmod +x ~/.local/bin/squasher

# Add to PATH (add this to your ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
squasher --help
```

### Manual Installation

1. **Clone or download the script:**
   ```bash
   git clone https://github.com/dev-gasy/squasher
   cd squash
   ```

2. **Install globally:**
   ```bash
   # Copy to system PATH
   sudo cp squasher.sh /usr/local/bin/squasher
   sudo chmod +x /usr/local/bin/squasher
   ```

3. **Or use locally:**
   ```bash
   # Make executable for local use
   chmod +x squasher.sh
   ./squasher.sh --help
   ```

4. **Verify installation:**
   ```bash
   squasher --help
   ```

## Usage

#### Basic Usage

```bash
# Squash with commit message (required)
squasher main -m "Feature: Complete user authentication system"

# Preview what would be squashed (dry-run, message still required)
squasher main --dry-run -m "Feature: Add payment processing"

# Interactive mode - will prompt for commit message
squasher main

# Force mode with message (confirmations skipped, but message required)
squasher develop -m "Bugfix: Fix memory leak" --force
```

#### Advanced Examples

```bash
# Combine multiple options
squasher develop -m "Bugfix: Memory leak in user service" --force --verbose

# Quiet mode for scripting (message required)
squasher main -m "Release v2.0" --quiet --force

# Verbose output with detailed logging
squasher feature-branch -m "Refactor database layer" --verbose
```

## Command Line Options

| Option              | Short | Description                               |
|---------------------|-------|-------------------------------------------|
| `--help`            | `-h`  | Show help message and examples            |
| `--version`         |       | Show version information                  |
| `--message MESSAGE` | `-m`  | **Required** commit message for squashed commit |
| `--dry-run`         |       | Preview changes without executing         |
| `--force`           | `-f`  | Skip confirmation prompts (message still required) |
| `--verbose`         | `-v`  | Enable detailed output                    |
| `--quiet`           | `-q`  | Suppress all output except errors         |

## Important Notes

- **Commit message is mandatory**: You must provide a commit message either via `-m` flag or interactively
- **Rewrites git history**: This operation cannot be easily undone
- **Use on feature branches**: Recommended for feature branches before merging
- **Backup important work**: Consider creating a backup branch before squashing
- **Team coordination**: Ensure team members are aware of history rewriting

## Prerequisites

- Git repository with at least one commit
- Target branch must exist
- Working directory must be clean (no uncommitted changes)
- Not currently on the target branch
- Commit message must be provided
