#Requires -Version 5.1

<#
.SYNOPSIS
    Git Commit Squasher - Squashes all commits on current branch from target branch into one commit

.DESCRIPTION
    A PowerShell script that provides enhanced Windows support for squashing git commits.
    This script validates the git repository, checks for uncommitted changes, shows a preview
    of commits to squash, and requires confirmation unless --Force is used.

.PARAMETER TargetBranch
    The target branch to squash commits from

.PARAMETER Message
    Custom commit message for the squashed commit

.PARAMETER DryRun
    Show what would happen without making changes

.PARAMETER Force
    Skip confirmation prompts

.PARAMETER Verbose
    Show detailed output

.PARAMETER Quiet
    Only show errors

.PARAMETER Help
    Show help message

.PARAMETER Version
    Show version information

.EXAMPLE
    .\squasher.ps1 main
    Squash all commits from main branch

.EXAMPLE
    .\squasher.ps1 main -DryRun
    Preview what would be squashed

.EXAMPLE
    .\squasher.ps1 main -Message "Feature: Complete user authentication system"
    Squash with custom commit message

.EXAMPLE
    .\squasher.ps1 develop -Force -Quiet
    Force mode with minimal output
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$TargetBranch,
    
    [Parameter()]
    [Alias("m")]
    [string]$Message = "",
    
    [Parameter()]
    [Alias("n")]
    [switch]$DryRun,
    
    [Parameter()]
    [Alias("f")]
    [switch]$Force,
    
    [Parameter()]
    [Alias("v")]
    [switch]$Verbose,
    
    [Parameter()]
    [Alias("q")]
    [switch]$Quiet,
    
    [Parameter()]
    [Alias("h")]
    [switch]$Help,
    
    [Parameter()]
    [switch]$Version
)

# Configuration
$script:ScriptName = $MyInvocation.MyCommand.Name
$script:ScriptVersion = "2.1"

# Colors for output
$script:Colors = @{
    Red    = "Red"
    Green  = "Green"
    Yellow = "Yellow"
    Blue   = "Blue"
    Reset  = "White"
}

# Show help
if ($Help) {
    Write-Host @"
Git Commit Squasher - Squash commits into one

USAGE:
    $script:ScriptName <target_branch> [options]

OPTIONS:
    -Message, -m MSG     Custom commit message
    -DryRun, -n          Show what would happen without changes
    -Force, -f           Skip confirmation prompts
    -Verbose, -v         Show detailed output
    -Quiet, -q           Only show errors
    -Help, -h            Show this help
    -Version             Show version

EXAMPLES:
    $script:ScriptName main
    $script:ScriptName main -DryRun
    $script:ScriptName main -Message "Feature: Add authentication"
    $script:ScriptName develop -Force -Quiet

SAFETY:
    - Validates git repository and branches
    - Checks for uncommitted changes
    - Shows preview of commits to squash
    - Requires confirmation unless -Force used
"@
    exit 0
}

# Show version
if ($Version) {
    Write-Host "$script:ScriptName v$script:ScriptVersion"
    exit 0
}

# Logging functions
function Write-Log {
    param([string]$Message, [string]$Color = "White")
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log "ERROR: $Message" $script:Colors.Red
}

function Write-Warning-Log {
    param([string]$Message)
    Write-Log "WARNING: $Message" $script:Colors.Yellow
}

function Write-Info-Log {
    param([string]$Message)
    Write-Log "INFO: $Message" $script:Colors.Blue
}

function Write-Success-Log {
    param([string]$Message)
    Write-Log "SUCCESS: $Message" $script:Colors.Green
}

function Write-Debug-Log {
    param([string]$Message)
    if ($Verbose) {
        Write-Log "DEBUG: $Message" $script:Colors.Reset
    }
}

function Stop-ScriptWithError {
    param([string]$Message, [int]$ExitCode = 1)
    Write-Error-Log $Message
    exit $ExitCode
}

# Git validation functions
function Test-GitRepository {
    try {
        $null = git rev-parse --git-dir 2>$null
        if ($LASTEXITCODE -ne 0) {
            Stop-ScriptWithError "Not in a git repository"
        }
        Write-Debug-Log "Git repository found"
    }
    catch {
        Stop-ScriptWithError "Not in a git repository"
    }
}

function Get-CurrentBranch {
    try {
        $branch = git branch --show-current 2>$null
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($branch)) {
            Stop-ScriptWithError "Could not determine current branch or detached HEAD state not supported"
        }
        return $branch.Trim()
    }
    catch {
        Stop-ScriptWithError "Could not determine current branch"
    }
}

function Test-BranchExists {
    param([string]$BranchName)
    try {
        $null = git show-ref --verify --quiet "refs/heads/$BranchName" 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Test-CleanWorkingDirectory {
    try {
        # Check for uncommitted changes
        $null = git diff-index --quiet HEAD -- 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Log "Uncommitted changes detected:"
            $changedFiles = git diff --name-only HEAD 2>$null | Select-Object -First 5
            $changedFiles | ForEach-Object { Write-Host "  $_" }
            Stop-ScriptWithError "Please commit or stash changes first"
        }

        # Check for untracked files
        $untrackedFiles = git ls-files --others --exclude-standard 2>$null | Select-Object -First 5
        if ($untrackedFiles) {
            Write-Warning-Log "Untracked files present:"
            $untrackedFiles | ForEach-Object { Write-Host "  $_" }
        }

        Write-Debug-Log "Working directory is clean"
    }
    catch {
        Stop-ScriptWithError "Failed to check working directory status"
    }
}

function Get-CommitInfo {
    param([string]$CurrentBranch, [string]$TargetBranch)
    try {
        $count = git rev-list --count "$TargetBranch..$CurrentBranch" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Stop-ScriptWithError "Failed to compare branches (does '$TargetBranch' exist?)"
        }
        return [int]$count
    }
    catch {
        Stop-ScriptWithError "Failed to get commit information"
    }
}

function Show-CommitsPreview {
    param([string]$CurrentBranch, [string]$TargetBranch)
    Write-Info-Log "Commits to be squashed:"
    if ($Verbose) {
        git log --oneline --graph "$TargetBranch..$CurrentBranch" | Select-Object -First 20
    } else {
        git log --oneline "$TargetBranch..$CurrentBranch" | Select-Object -First 10
    }
}

function Confirm-Operation {
    param([int]$CommitCount, [string]$CurrentBranch)
    
    if ($Force) {
        return $true
    }

    Write-Warning-Log "This will squash $CommitCount commits on '$CurrentBranch' into one commit"
    Write-Warning-Log "This rewrites git history and cannot be easily undone"
    Write-Host ""

    $response = Read-Host "Continue? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Info-Log "Operation cancelled"
        exit 0
    }
    return $true
}

function Get-SquashMessage {
    param([int]$CommitCount, [string]$CurrentBranch)
    
    # Use provided message if available
    if (-not [string]::IsNullOrEmpty($Message)) {
        return $Message
    }

    $defaultMsg = "Squash $CommitCount commits from $CurrentBranch"

    # Use default in force mode
    if ($Force) {
        return $defaultMsg
    }

    # Interactive message input
    Write-Host ""
    Write-Info-Log "Enter commit message (press Enter for default):"
    Write-Host "Default: $defaultMsg"
    $userMessage = Read-Host "Message"

    if ([string]::IsNullOrEmpty($userMessage)) {
        return $defaultMsg
    }
    return $userMessage
}

function Invoke-Squash {
    param([string]$TargetBranch, [int]$CommitCount, [string]$CurrentBranch)
    
    Write-Info-Log "Squashing $CommitCount commits..."

    try {
        # Soft reset to target branch
        git reset --soft $TargetBranch 2>$null
        if ($LASTEXITCODE -ne 0) {
            Stop-ScriptWithError "Failed to reset to '$TargetBranch'"
        }

        # Check if there are changes to commit
        $null = git diff --cached --quiet 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Warning-Log "No changes after reset - nothing to squash"
            return
        }

        # Get commit message
        $commitMessage = Get-SquashMessage $CommitCount $CurrentBranch

        # Create the squashed commit
        git commit -m $commitMessage 2>$null
        if ($LASTEXITCODE -ne 0) {
            Stop-ScriptWithError "Failed to create commit"
        }

        Write-Success-Log "Squashed $CommitCount commits into one!"
        $newCommit = git log --oneline -n 1
        Write-Success-Log "New commit: $newCommit"

        # Show commit details if verbose
        if ($Verbose) {
            Write-Host ""
            git show --stat HEAD
        }
    }
    catch {
        Stop-ScriptWithError "Failed to perform squash operation"
    }
}

function Invoke-DryRun {
    param([int]$CommitCount, [string]$CurrentBranch, [string]$TargetBranch)
    
    Write-Info-Log "DRY RUN MODE" $script:Colors.Yellow
    Write-Info-Log "Would squash $CommitCount commits on '$CurrentBranch'"

    $msg = $Message
    if ([string]::IsNullOrEmpty($msg)) {
        $msg = "Squash $CommitCount commits from $CurrentBranch"
    }
    Write-Info-Log "Commit message: `"$msg`""

    if ($Verbose) {
        Write-Host ""
        Write-Info-Log "Commands that would be executed:"
        Write-Host "  git reset --soft '$TargetBranch'"
        Write-Host "  git commit -m '$msg'"
    }

    Write-Success-Log "Dry run completed"
}

# Main execution
function Main {
    Write-Debug-Log "Starting $script:ScriptName v$script:ScriptVersion"

    # Validate environment
    Test-GitRepository

    $currentBranch = Get-CurrentBranch

    if (-not (Test-BranchExists $TargetBranch)) {
        Stop-ScriptWithError "Branch '$TargetBranch' does not exist"
    }

    if ($currentBranch -eq $TargetBranch) {
        Stop-ScriptWithError "Cannot squash commits on the target branch itself"
    }

    Test-CleanWorkingDirectory

    $commitCount = Get-CommitInfo $currentBranch $TargetBranch

    if ($commitCount -eq 0) {
        Write-Info-Log "No commits to squash on '$currentBranch'"
        exit 0
    }

    Write-Info-Log "Found $commitCount commits to squash"
    Show-CommitsPreview $currentBranch $TargetBranch

    # Execute operation
    if ($DryRun) {
        Invoke-DryRun $commitCount $currentBranch $TargetBranch
    } else {
        Confirm-Operation $commitCount $currentBranch
        Invoke-Squash $TargetBranch $commitCount $currentBranch
    }

    Write-Debug-Log "Operation completed successfully"
}

# Run the main function
try {
    Main
}
catch {
    Write-Error-Log "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}