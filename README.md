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
# Squash all commits from main branch
squasher main

# Preview what would be squashed (dry-run)
squasher main --dry-run

# Squash with custom commit message
squasher main -m "Feature: Complete user authentication system"

# Force mode (skip confirmations)
squasher develop --force

# Verbose output with detailed logging
squasher main --verbose --dry-run
```

#### Advanced Examples

```bash
# Combine multiple options
squasher develop --message "Bugfix: Memory leak in user service" --force --verbose

# Quiet mode for scripting
squasher main -m "Release v2.0" --quiet

# Interactive mode with preview
squasher feature-branch
```

## Command Line Options

| Option              | Short | Description                               |
|---------------------|-------|-------------------------------------------|
| `--help`            | `-h`  | Show help message and examples            |
| `--version`         |       | Show version information                  |
| `--message MESSAGE` | `-m`  | Custom commit message for squashed commit |
| `--dry-run`         |       | Preview changes without executing         |
| `--force`           | `-f`  | Skip confirmation prompts                 |
| `--verbose`         | `-v`  | Enable detailed output                    |
| `--quiet`           | `-q`  | Suppress all output except errors         |

## Important Notes

- **Rewrites git history**: This operation cannot be easily undone
- **Use on feature branches**: Recommended for feature branches before merging
- **Backup important work**: Consider creating a backup branch before squashing
- **Team coordination**: Ensure team members are aware of history rewriting

## Prerequisites

- Git repository with at least one commit
- Target branch must exist
- Working directory must be clean (no uncommitted changes)
- Not currently on the target branch
