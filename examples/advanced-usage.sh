#!/usr/bin/env bash

# Advanced Usage Example - Demonstrates various squasher options
# This script shows different ways to use squasher with various flags

set -e

echo "=== Squasher Advanced Usage Examples ==="
echo

# Function to create a test repository
setup_repo() {
    local repo_name=$1
    rm -rf "$repo_name"
    mkdir "$repo_name"
    cd "$repo_name"
    
    git init --quiet
    git config user.email "demo@example.com"
    git config user.name "Demo User"
    
    # Create base commits
    echo "Initial" > README.md
    git add README.md
    git commit -m "Initial commit" --quiet
    
    git checkout -b feature/work --quiet
    
    # Create multiple commits
    for i in {1..3}; do
        echo "Line $i" >> README.md
        git add README.md
        git commit -m "Add line $i" --quiet
    done
}

# Example 1: Verbose mode with stats
echo "=== Example 1: Verbose mode with statistics ==="
setup_repo "example1"
echo "Running: squasher main -m \"Feature complete\" --verbose --stats"
echo "----------------------------------------"
../../squasher.sh main -m "Feature complete" --verbose --stats --force
cd ..
echo

# Example 2: Quiet mode for scripting
echo "=== Example 2: Quiet mode (for scripts/automation) ==="
setup_repo "example2"
echo "Running: squasher main -m \"Automated squash\" --quiet --force"
echo "----------------------------------------"
../../squasher.sh main -m "Automated squash" --quiet --force
echo "Exit code: $?"
echo "Note: In quiet mode, only errors are shown"
cd ..
echo

# Example 3: Dry run with backup preview
echo "=== Example 3: Dry run with backup option ==="
setup_repo "example3"
echo "Running: squasher main -m \"Testing squash\" --dry-run --backup --verbose"
echo "----------------------------------------"
../../squasher.sh main -m "Testing squash" --dry-run --backup --verbose
cd ..
echo

# Example 4: Interactive mode
echo "=== Example 4: Interactive mode (no message flag) ==="
setup_repo "example4"
echo "Running: squasher main (will prompt for message)"
echo "----------------------------------------"
# Use echo to provide input non-interactively for demo
echo "Interactive commit message" | ../../squasher.sh main
cd ..
echo

# Example 5: Error handling demo
echo "=== Example 5: Error handling demonstrations ==="
echo

echo "5a. Attempting to squash with uncommitted changes:"
setup_repo "example5a"
echo "Uncommitted change" >> README.md
echo "Running: squasher main -m \"Will fail\""
echo "----------------------------------------"
../../squasher.sh main -m "Will fail" 2>&1 || echo "Command failed as expected"
cd ..
echo

echo "5b. Attempting to squash on non-existent branch:"
setup_repo "example5b"
echo "Running: squasher nonexistent -m \"Will fail\""
echo "----------------------------------------"
../../squasher.sh nonexistent -m "Will fail" 2>&1 || echo "Command failed as expected"
cd ..
echo

echo "5c. Attempting to squash on same branch:"
setup_repo "example5c"
git checkout main --quiet
echo "Running: squasher main -m \"Will fail\""
echo "----------------------------------------"
../../squasher.sh main -m "Will fail" 2>&1 || echo "Command failed as expected"
cd ..

# Cleanup
echo
echo "=== Cleanup ==="
echo "Removing example directories..."
rm -rf example1 example2 example3 example4 example5a example5b example5c

echo
echo "Advanced usage examples complete!"
echo
echo "Key takeaways:"
echo "• Use --verbose for detailed output during debugging"
echo "• Use --quiet --force for automation and CI/CD pipelines"
echo "• Always test with --dry-run before important operations"
echo "• Combine --backup with --stats for maximum safety and information"
echo "• The tool validates git state and provides clear error messages"
