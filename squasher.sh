#!/usr/bin/env bash

# Git Commit Squasher
# Squashes all commits on current branch from target branch into one commit

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="2.2"

# Default values
DRY_RUN=false
FORCE=false
QUIET=false
VERBOSE=false
BACKUP=false
STATS=false
TARGET_BRANCH=""
COMMIT_MESSAGE=""

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log() { [[ "$QUIET" == "true" ]] || echo -e "$@"; }
error() { log "${RED}ERROR:${NC} $*" >&2; }
warn() { log "${YELLOW}WARNING:${NC} $*"; }
info() { log "${BLUE}INFO:${NC} $*"; }
success() { log "${GREEN}SUCCESS:${NC} $*"; }
debug() { [[ "$VERBOSE" == "true" ]] && log "DEBUG: $*" >&2 || true; }

die() {
    error "$1"
    exit "${2:-1}"
}

show_help() {
    cat << 'EOF'

  ███████╗ ██████╗ ██╗   ██╗ █████╗ ███████╗██╗  ██╗███████╗██████╗ 
  ██╔════╝██╔═══██╗██║   ██║██╔══██╗██╔════╝██║  ██║██╔════╝██╔══██╗
  ███████╗██║   ██║██║   ██║███████║███████╗███████║█████╗  ██████╔╝
  ╚════██║██║   ██║██║   ██║██╔══██║╚════██║██╔══██║██╔══╝  ██╔══██╗
  ███████║╚██████╔╝╚██████╔╝██║  ██║███████║██║  ██║███████╗██║  ██║
  ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

Git Commits Squasher - Squash commits into one

USAGE:
    squasher <target_branch> [options]

OPTIONS:
    -m, --message MSG    Custom commit message
    -n, --dry-run        Show what would happen without changes
    -f, --force          Skip confirmation prompts
    -v, --verbose        Show detailed output
    -q, --quiet          Only show errors
    -b, --backup         Create backup branch before squashing
    -s, --stats          Show commit statistics after squashing
    -h, --help           Show this help
    --version            Show version

EXAMPLES:
    squasher main -m "Implement user authentication system"
    squasher main --dry-run -m "Fix critical security vulnerability"
    squasher develop -m "Add payment processing feature" --force --backup
    squasher feature-branch -m "Refactor database layer" --verbose --stats
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0 ;;
            --version) echo "$SCRIPT_NAME v$VERSION"; exit 0 ;;
            -n|--dry-run) DRY_RUN=true ;;
            -f|--force) FORCE=true ;;
            -v|--verbose) VERBOSE=true ;;
            -q|--quiet) QUIET=true ;;
            -b|--backup) BACKUP=true ;;
            -s|--stats) STATS=true ;;
            -m|--message)
                [[ -n "${2:-}" ]] || die "Option $1 requires an argument"
                COMMIT_MESSAGE="$2"
                shift ;;
            -*) die "Unknown option: $1" ;;
            *)
                [[ -z "$TARGET_BRANCH" ]] || die "Too many arguments: $1"
                TARGET_BRANCH="$1" ;;
        esac
        shift
    done

    [[ -n "$TARGET_BRANCH" ]] || die "Target branch is required"
}

# Git validation functions
check_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1 || die "Not in a git repository"
    debug "Git repository found"
}

get_current_branch() {
    local branch
    branch=$(git branch --show-current 2>/dev/null) || die "Could not determine current branch"
    [[ -n "$branch" ]] || die "Detached HEAD state not supported"
    echo "$branch"
}

branch_exists() {
    git show-ref --verify --quiet "refs/heads/$1" 2>/dev/null
}

check_clean_working_dir() {
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        error "Uncommitted changes detected:"
        git diff --name-only HEAD 2>/dev/null | head -5
        die "Please commit or stash changes first"
    fi

    # Check for untracked files that might be important
    local untracked
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null | head -5)
    if [[ -n "$untracked" ]]; then
        warn "Untracked files present:"
        echo "$untracked"
    fi

    debug "Working directory is clean"
}

get_commit_info() {
    local current_branch="$1"
    local target_branch="$2"

    local count
    count=$(git rev-list --count "${target_branch}..${current_branch}" 2>/dev/null) || \
        die "Failed to compare branches (does '$target_branch' exist?)"

    echo "$count"
}

show_commits_preview() {
    local current_branch="$1"
    local target_branch="$2"

    info "Commits to be squashed:"
    if [[ "$VERBOSE" == "true" ]]; then
        git log --oneline --graph "${target_branch}..${current_branch}" | head -20
    else
        git log --oneline "${target_branch}..${current_branch}" | head -10
    fi
}

confirm_operation() {
    local commit_count="$1"
    local current_branch="$2"

    [[ "$FORCE" == "true" ]] && return 0

    warn "This will squash $commit_count commits on '$current_branch' into one commit"
    warn "This rewrites git history and cannot be easily undone"
    echo

    local response
    read -p "Continue? (y/n): " -n 1 -r response
    echo
    [[ $response =~ ^[Yy]$ ]] || { info "Operation cancelled"; exit 0; }
}

get_squash_message() {
    local commit_count="$1"
    local current_branch="$2"

    # Use provided message if available
    [[ -n "$COMMIT_MESSAGE" ]] && return 0

    # Use default in force mode
    if [[ "$FORCE" == "true" ]]; then
        die "Commit message is required. Use -m or --message to provide one."
    fi

    # Interactive message input - mandatory
    echo
    info "Enter commit message (required):"
    while true; do
        read -p "Message: " -r COMMIT_MESSAGE
        [[ -n "$COMMIT_MESSAGE" ]] && break
        error "Commit message cannot be empty. Please provide a message."
    done
}

create_backup_branch() {
    local current_branch="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_branch="backup/${current_branch}-${timestamp}"
    
    info "Creating backup branch: $backup_branch"
    git branch "$backup_branch" || die "Failed to create backup branch"
    
    # Store backup info for potential recovery
    echo "$backup_branch" > .git/squasher_backup
    
    success "Backup created: $backup_branch"
}

perform_squash() {
    local target_branch="$1"
    local commit_count="$2"
    local old_ref=$(git rev-parse HEAD)

    # Create backup if requested
    if [[ "$BACKUP" == "true" ]] && [[ "$DRY_RUN" != "true" ]]; then
        create_backup_branch "$CURRENT_BRANCH"
    fi

    info "Squashing $commit_count commits..."

    # Soft reset to target branch
    git reset --soft "$target_branch" || die "Failed to reset to '$target_branch'"

    # Check if there are changes to commit
    if git diff --cached --quiet; then
        warn "No changes after reset - nothing to squash"
        return 0
    fi

    # Get commit message
    get_squash_message "$commit_count" "$CURRENT_BRANCH"

    # Create the squashed commit
    git commit -m "$COMMIT_MESSAGE" || die "Failed to create commit"

    success "Squashed $commit_count commits into one!"
    success "New commit: $(git log --oneline -n 1)"

    # Show statistics if requested
    if [[ "$STATS" == "true" ]]; then
        echo
        info "Commit statistics:"
        git diff --stat "$old_ref" HEAD
    fi

    # Show commit details if verbose
    if [[ "$VERBOSE" == "true" ]]; then
        echo
        git show --stat HEAD
    fi
}

run_dry_run() {
    local commit_count="$1"
    local current_branch="$2"
    local target_branch="$3"

    info "${YELLOW}DRY RUN MODE${NC}"
    info "Would squash $commit_count commits on '$current_branch'"

    # Get commit message (required even for dry run)
    get_squash_message "$commit_count" "$current_branch"
    
    info "Commit message: \"$COMMIT_MESSAGE\""
    
    if [[ "$BACKUP" == "true" ]]; then
        info "Would create backup branch before squashing"
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        echo
        info "Commands that would be executed:"
        [[ "$BACKUP" == "true" ]] && echo "  git branch 'backup/$current_branch-<timestamp>'"
        echo "  git reset --soft '$target_branch'"
        echo "  git commit -m '$COMMIT_MESSAGE'"
        [[ "$STATS" == "true" ]] && echo "  git diff --stat <old-ref> HEAD"
    fi

    success "Dry run completed"
}

main() {
    debug "Starting $SCRIPT_NAME v$VERSION"

    # Validate environment
    check_git_repo

    local current_branch
    current_branch=$(get_current_branch)

    branch_exists "$TARGET_BRANCH" || die "Branch '$TARGET_BRANCH' does not exist"

    [[ "$current_branch" != "$TARGET_BRANCH" ]] || \
        die "Cannot squash commits on the target branch itself"

    check_clean_working_dir

    local commit_count
    commit_count=$(get_commit_info "$current_branch" "$TARGET_BRANCH")

    if [[ "$commit_count" -eq 0 ]]; then
        info "No commits to squash on '$current_branch'"
        exit 0
    fi

    info "Found $commit_count commits to squash"
    show_commits_preview "$current_branch" "$TARGET_BRANCH"

    # Export for other functions
    readonly CURRENT_BRANCH="$current_branch"

    # Execute operation
    if [[ "$DRY_RUN" == "true" ]]; then
        run_dry_run "$commit_count" "$current_branch" "$TARGET_BRANCH"
    else
        confirm_operation "$commit_count" "$current_branch"
        perform_squash "$TARGET_BRANCH" "$commit_count"
    fi

    debug "Operation completed successfully"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_args "$@"
    main
fi
