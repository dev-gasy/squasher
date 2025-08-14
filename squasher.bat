@echo off
setlocal enabledelayedexpansion

:: Git Commit Squasher - Windows Batch Script
:: Squashes all commits on current branch from target branch into one commit

:: Configuration
set "SCRIPT_NAME=%~nx0"
set "VERSION=2.1"

:: Default values
set "DRY_RUN=false"
set "FORCE=false"
set "QUIET=false"
set "VERBOSE=false"
set "TARGET_BRANCH="
set "COMMIT_MESSAGE="

:: Parse command line arguments
:parse_args
if "%~1"=="" goto validate_args
if /i "%~1"=="-h" goto show_help
if /i "%~1"=="--help" goto show_help
if /i "%~1"=="--version" goto show_version
if /i "%~1"=="-n" (
    set "DRY_RUN=true"
    shift & goto parse_args
)
if /i "%~1"=="--dry-run" (
    set "DRY_RUN=true"
    shift & goto parse_args
)
if /i "%~1"=="-f" (
    set "FORCE=true"
    shift & goto parse_args
)
if /i "%~1"=="--force" (
    set "FORCE=true"
    shift & goto parse_args
)
if /i "%~1"=="-v" (
    set "VERBOSE=true"
    shift & goto parse_args
)
if /i "%~1"=="--verbose" (
    set "VERBOSE=true"
    shift & goto parse_args
)
if /i "%~1"=="-q" (
    set "QUIET=true"
    shift & goto parse_args
)
if /i "%~1"=="--quiet" (
    set "QUIET=true"
    shift & goto parse_args
)
if /i "%~1"=="-m" (
    if "%~2"=="" (
        call :error "Option %~1 requires an argument"
        exit /b 1
    )
    set "COMMIT_MESSAGE=%~2"
    shift & shift & goto parse_args
)
if /i "%~1"=="--message" (
    if "%~2"=="" (
        call :error "Option %~1 requires an argument"
        exit /b 1
    )
    set "COMMIT_MESSAGE=%~2"
    shift & shift & goto parse_args
)
if "%~1:~0,1%"=="-" (
    call :error "Unknown option: %~1"
    exit /b 1
)
if not "%TARGET_BRANCH%"=="" (
    call :error "Too many arguments: %~1"
    exit /b 1
)
set "TARGET_BRANCH=%~1"
shift & goto parse_args

:validate_args
if "%TARGET_BRANCH%"=="" (
    call :error "Target branch is required"
    exit /b 1
)
goto main

:show_help
echo Git Commit Squasher - Squash commits into one
echo.
echo USAGE:
echo     %SCRIPT_NAME% ^<target_branch^> [options]
echo.
echo OPTIONS:
echo     -m, --message MSG    Custom commit message
echo     -n, --dry-run        Show what would happen without changes
echo     -f, --force          Skip confirmation prompts
echo     -v, --verbose        Show detailed output
echo     -q, --quiet          Only show errors
echo     -h, --help           Show this help
echo     --version            Show version
echo.
echo EXAMPLES:
echo     %SCRIPT_NAME% main
echo     %SCRIPT_NAME% main --dry-run
echo     %SCRIPT_NAME% main -m "Feature: Add authentication"
echo     %SCRIPT_NAME% develop --force --quiet
echo.
echo SAFETY:
echo     - Validates git repository and branches
echo     - Checks for uncommitted changes
echo     - Shows preview of commits to squash
echo     - Requires confirmation unless --force used
exit /b 0

:show_version
echo %SCRIPT_NAME% v%VERSION%
exit /b 0

:: Logging functions
:log
if "%QUIET%"=="true" exit /b 0
echo %*
exit /b 0

:error
call :log ERROR: %*
exit /b 0

:warn
call :log WARNING: %*
exit /b 0

:info
call :log INFO: %*
exit /b 0

:success
call :log SUCCESS: %*
exit /b 0

:debug
if "%VERBOSE%"=="true" call :log DEBUG: %*
exit /b 0

:die
call :error %1
exit /b %2

:: Git validation functions
:check_git_repo
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    call :die "Not in a git repository" 1
)
call :debug "Git repository found"
exit /b 0

:get_current_branch
for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set "CURRENT_BRANCH=%%i"
if "%CURRENT_BRANCH%"=="" (
    call :die "Could not determine current branch or detached HEAD state not supported" 1
)
exit /b 0

:branch_exists
git show-ref --verify --quiet "refs/heads/%~1" >nul 2>&1
exit /b %errorlevel%

:check_clean_working_dir
git diff-index --quiet HEAD -- >nul 2>&1
if errorlevel 1 (
    call :error "Uncommitted changes detected:"
    git diff --name-only HEAD 2>nul
    call :die "Please commit or stash changes first" 1
)

:: Check for untracked files
for /f "tokens=*" %%i in ('git ls-files --others --exclude-standard 2^>nul') do (
    call :warn "Untracked files present:"
    git ls-files --others --exclude-standard 2>nul
    goto clean_done
)

:clean_done
call :debug "Working directory is clean"
exit /b 0

:get_commit_info
for /f "tokens=*" %%i in ('git rev-list --count "%TARGET_BRANCH%..%CURRENT_BRANCH%" 2^>nul') do set "COMMIT_COUNT=%%i"
if errorlevel 1 (
    call :die "Failed to compare branches (does '%TARGET_BRANCH%' exist?)" 1
)
exit /b 0

:show_commits_preview
call :info "Commits to be squashed:"
if "%VERBOSE%"=="true" (
    git log --oneline --graph "%TARGET_BRANCH%..%CURRENT_BRANCH%"
) else (
    git log --oneline "%TARGET_BRANCH%..%CURRENT_BRANCH%"
)
exit /b 0

:confirm_operation
if "%FORCE%"=="true" exit /b 0

call :warn "This will squash %COMMIT_COUNT% commits on '%CURRENT_BRANCH%' into one commit"
call :warn "This rewrites git history and cannot be easily undone"
echo.

set /p "response=Continue? (y/N): "
if /i not "%response%"=="y" (
    call :info "Operation cancelled"
    exit /b 0
)
exit /b 0

:get_squash_message
if not "%COMMIT_MESSAGE%"=="" exit /b 0

set "default_msg=Squash %COMMIT_COUNT% commits from %CURRENT_BRANCH%"

if "%FORCE%"=="true" (
    set "COMMIT_MESSAGE=%default_msg%"
    exit /b 0
)

echo.
call :info "Enter commit message (press Enter for default):"
echo Default: %default_msg%
set /p "COMMIT_MESSAGE=Message: "

if "%COMMIT_MESSAGE%"=="" set "COMMIT_MESSAGE=%default_msg%"
exit /b 0

:perform_squash
call :info "Squashing %COMMIT_COUNT% commits..."

git reset --soft "%TARGET_BRANCH%"
if errorlevel 1 (
    call :die "Failed to reset to '%TARGET_BRANCH%'" 1
)

git diff --cached --quiet >nul 2>&1
if not errorlevel 1 (
    call :warn "No changes after reset - nothing to squash"
    exit /b 0
)

call :get_squash_message

git commit -m "%COMMIT_MESSAGE%"
if errorlevel 1 (
    call :die "Failed to create commit" 1
)

call :success "Squashed %COMMIT_COUNT% commits into one!"

for /f "tokens=*" %%i in ('git log --oneline -n 1') do (
    call :success "New commit: %%i"
)

if "%VERBOSE%"=="true" (
    echo.
    git show --stat HEAD
)
exit /b 0

:run_dry_run
call :info "DRY RUN MODE"
call :info "Would squash %COMMIT_COUNT% commits on '%CURRENT_BRANCH%'"

set "msg=%COMMIT_MESSAGE%"
if "%msg%"=="" set "msg=Squash %COMMIT_COUNT% commits from %CURRENT_BRANCH%"
call :info "Commit message: \"%msg%\""

if "%VERBOSE%"=="true" (
    echo.
    call :info "Commands that would be executed:"
    echo   git reset --soft '%TARGET_BRANCH%'
    echo   git commit -m '%msg%'
)

call :success "Dry run completed"
exit /b 0

:main
call :debug "Starting %SCRIPT_NAME% v%VERSION%"

call :check_git_repo
call :get_current_branch

call :branch_exists "%TARGET_BRANCH%"
if errorlevel 1 (
    call :die "Branch '%TARGET_BRANCH%' does not exist" 1
)

if "%CURRENT_BRANCH%"=="%TARGET_BRANCH%" (
    call :die "Cannot squash commits on the target branch itself" 1
)

call :check_clean_working_dir
call :get_commit_info

if "%COMMIT_COUNT%"=="0" (
    call :info "No commits to squash on '%CURRENT_BRANCH%'"
    exit /b 0
)

call :info "Found %COMMIT_COUNT% commits to squash"
call :show_commits_preview

if "%DRY_RUN%"=="true" (
    call :run_dry_run
) else (
    call :confirm_operation
    call :perform_squash
)

call :debug "Operation completed successfully"
exit /b 0