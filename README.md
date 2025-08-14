# Git Commit Squasher

[![Version](https://img.shields.io/badge/version-2.1-blue.svg)](https://github.com/dev-gasy/squasher/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/dev-gasy/squasher)

A powerful bash script to squash multiple git commits into a single commit with safety features and interactive options.

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
   cd squasher
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

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [How It Works](#how-it-works)
- [Command Line Options](#command-line-options)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Features

- ✅ **Safe Operation**: Validates git state before making changes
- 🔍 **Dry Run Mode**: Preview changes without executing
- 💬 **Interactive Mode**: Guided commit message input
- 🚀 **Force Mode**: Skip confirmations for automation
- 📊 **Verbose Output**: Detailed logging for debugging
- 🔇 **Quiet Mode**: Minimal output for scripting
- 🎯 **Smart Validation**: Checks for clean working directory and branch existence
- 🛡️ **Error Prevention**: Prevents common mistakes like squashing on target branch

## Usage

### Basic Usage

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

### Advanced Examples

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

## How It Works

`squasher` simplifies the git squashing process by:

1. **Validating** your current git state
2. **Identifying** commits to squash (from target branch to current branch)
3. **Soft resetting** to the target branch (preserving all changes)
4. **Creating** a single new commit with your message

```
Before:                          After:
main ──A──B                      main ──A──B
           \                                \
   feature  C──D──E──F           feature     X (squashed)
```

## Best Practices

- **Create a backup branch** before squashing important work:
  ```bash
  git branch backup/feature-before-squash
  ```

- **Use descriptive commit messages** that summarize all squashed work

- **Squash before merging** to keep main branch history clean

- **Coordinate with team** when rewriting shared branch history

- **Use dry-run first** to preview what will be squashed

## Troubleshooting

### Common Issues

**Error: "Uncommitted changes detected"**
- Solution: Commit or stash your changes first
  ```bash
  git stash  # or git commit -am "WIP"
  ```

**Error: "Cannot squash commits on the target branch itself"**
- Solution: You must be on a different branch than the target
  ```bash
  git checkout feature-branch
  squasher main -m "Your message"
  ```

**Error: "Branch 'X' does not exist"**
- Solution: Verify branch name with `git branch -a`

### Recovering from Mistakes

If you need to undo a squash:
```bash
# Find the commit before squashing
git reflog

# Reset to that commit
git reset --hard HEAD@{n}  # where n is the reflog entry
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Prerequisites

- Git repository with at least one commit
- Target branch must exist
- Working directory must be clean (no uncommitted changes)
- Not currently on the target branch
- Commit message must be provided
