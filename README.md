# Git Commit Squasher

A cross-platform tool to squash multiple git commits into a single commit. Available as bash script (Linux/macOS), PowerShell script (Windows), and batch script (Windows).

## Installation

### Linux/macOS - Quick Install (Recommended)

```bash
# Download and install globally
sudo curl -o /usr/local/bin/squasher https://raw.githubusercontent.com/dev-gasy/squasher/main/squasher.sh
sudo chmod +x /usr/local/bin/squasher

# Verify installation
squasher --help
```

### Windows - PowerShell (Recommended)

```powershell
# Download PowerShell script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dev-gasy/squasher/main/squasher.ps1" -OutFile "$env:USERPROFILE\squasher.ps1"

# Run from anywhere by adding to your PowerShell profile
Add-Content $PROFILE "`nSet-Alias squasher `"$env:USERPROFILE\squasher.ps1`""

# Or create a global function (run as Administrator)
$scriptPath = "$env:ProgramFiles\WindowsPowerShell\Scripts\squasher.ps1"
New-Item -Path (Split-Path $scriptPath) -ItemType Directory -Force
Copy-Item "$env:USERPROFILE\squasher.ps1" $scriptPath

# Verify installation
squasher --help
```

### Windows - Batch Script

```cmd
# Download batch script
curl -o "%USERPROFILE%\squasher.bat" https://raw.githubusercontent.com/dev-gasy/squasher/main/squasher.bat

# Add to PATH or run directly
# To add to PATH: copy squasher.bat to a directory in your PATH
# Or run directly: "%USERPROFILE%\squasher.bat" main

# Verify installation
squasher --help
```

### Linux/macOS - Alternative Installation (if sudo not available)

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

#### Linux/macOS

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

#### Windows

1. **Clone or download the repository:**
   ```cmd
   git clone https://github.com/dev-gasy/squasher
   cd squash
   ```

2. **For PowerShell:**
   ```powershell
   # Copy to Scripts directory
   Copy-Item "squasher.ps1" "$env:ProgramFiles\WindowsPowerShell\Scripts\"
   ```

3. **For Batch script:**
   ```cmd
   # Copy to a directory in PATH or use locally
   copy squasher.bat "%USERPROFILE%\squasher.bat"
   ```

4. **Verify installation:**
   ```bash
   squasher --help
   ```

## Usage

#### Basic Usage

**Linux/macOS (Bash):**
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

**Windows (PowerShell):**
```powershell
# Squash all commits from main branch
squasher main

# Preview what would be squashed (dry-run)
squasher main -DryRun

# Squash with custom commit message
squasher main -Message "Feature: Complete user authentication system"

# Force mode (skip confirmations)
squasher develop -Force

# Verbose output with detailed logging
squasher main -Verbose -DryRun
```

**Windows (Batch):**
```cmd
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

**Cross-platform examples:**
```bash
# Combine multiple options (Bash/Batch)
squasher develop --message "Bugfix: Memory leak in user service" --force --verbose

# PowerShell equivalent
squasher develop -Message "Bugfix: Memory leak in user service" -Force -Verbose

# Quiet mode for scripting (Bash/Batch)
squasher main -m "Release v2.0" --quiet

# PowerShell equivalent
squasher main -Message "Release v2.0" -Quiet

# Interactive mode with preview
squasher feature-branch
```

## Command Line Options

### Bash/Batch Script Options

| Option              | Short | Description                               |
|---------------------|-------|-------------------------------------------|
| `--help`            | `-h`  | Show help message and examples            |
| `--version`         |       | Show version information                  |
| `--message MESSAGE` | `-m`  | Custom commit message for squashed commit |
| `--dry-run`         | `-n`  | Preview changes without executing         |
| `--force`           | `-f`  | Skip confirmation prompts                 |
| `--verbose`         | `-v`  | Enable detailed output                    |
| `--quiet`           | `-q`  | Suppress all output except errors         |

### PowerShell Script Options

| Option              | Alias | Description                               |
|---------------------|-------|-------------------------------------------|
| `-Help`             | `-h`  | Show help message and examples            |
| `-Version`          |       | Show version information                  |
| `-Message`          | `-m`  | Custom commit message for squashed commit |
| `-DryRun`           | `-n`  | Preview changes without executing         |
| `-Force`            | `-f`  | Skip confirmation prompts                 |
| `-Verbose`          | `-v`  | Enable detailed output                    |
| `-Quiet`            | `-q`  | Suppress all output except errors         |

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

### Platform-Specific Requirements

**Linux/macOS:**
- Bash shell
- Git command line tools

**Windows:**
- **PowerShell:** PowerShell 5.1 or later (recommended)
- **Batch:** Windows Command Prompt with Git for Windows
- Git command line tools
