#!/usr/bin/env bash

# Undo Demo - Demonstrates how to recover from squashing
# This script shows different ways to undo a squash operation

set -e

echo "=== Squasher Undo/Recovery Demo ==="
echo

# Create a temporary directory for the demo
DEMO_DIR="test-repo-undo"
rm -rf "$DEMO_DIR"
mkdir "$DEMO_DIR"
cd "$DEMO_DIR"

echo "1. Setting up demo repository..."
git init --quiet
git config user.email "demo@example.com"
git config user.name "Demo User"

# Create initial commits
echo "Initial content" > file1.txt
git add file1.txt
git commit -m "Initial commit" --quiet

git checkout -b feature/demo --quiet

# Create commits to squash
for i in {1..5}; do
    echo "Change $i" >> file1.txt
    git add file1.txt
    git commit -m "Change $i" --quiet
done

echo
echo "2. Original commit history:"
git log --oneline main..HEAD

# Save the current commit hash for recovery demo
ORIGINAL_HEAD=$(git rev-parse HEAD)

echo
echo "3. Squashing commits WITH backup option..."
../../squasher.sh main -m "Feature: All changes squashed" --backup --force

echo
echo "4. After squashing:"
git log --oneline main..HEAD

echo
echo "=== Recovery Method 1: Using backup branch ==="
if [ -f .git/squasher_backup ]; then
    BACKUP_BRANCH=$(cat .git/squasher_backup)
    echo "5. Backup branch found: $BACKUP_BRANCH"
    echo "   Restoring from backup..."
    git reset --hard "$BACKUP_BRANCH"
    echo "   Restored! Current history:"
    git log --oneline main..HEAD
else
    echo "5. No backup branch found (backup option might not have been used)"
fi

# Reset for next demo
echo
echo "6. Squashing again (without backup) for reflog demo..."
git reset --hard "$ORIGINAL_HEAD" --quiet
../../squasher.sh main -m "Feature: Squashed again" --force --quiet

echo
echo "=== Recovery Method 2: Using git reflog ==="
echo "7. Git reflog shows our history:"
git reflog -5

echo
echo "8. Finding the commit before squashing..."
# In a real scenario, you'd manually identify the correct reflog entry
echo "   You would look for the commit before 'commit: Feature: Squashed again'"
echo "   Then run: git reset --hard HEAD@{n}"
echo "   where 'n' is the reflog index"

echo
echo "9. Demonstrating reflog recovery:"
# This finds the entry before our squash commit
REFLOG_INDEX=$(git reflog | grep -B1 "commit: Feature: Squashed again" | head -1 | cut -d' ' -f1 | cut -d'@' -f2 | tr -d '{}:')
if [ -n "$REFLOG_INDEX" ]; then
    echo "   Found previous state at HEAD@{$REFLOG_INDEX}"
    git reset --hard "HEAD@{$REFLOG_INDEX}"
    echo "   Restored! Current history:"
    git log --oneline main..HEAD
fi

echo
echo "=== Key Takeaways ==="
echo "• Always use --backup when squashing important work"
echo "• Git reflog is your safety net (but expires after 90 days by default)"
echo "• Create manual backup branches for critical work: git branch backup/before-squash"
echo "• Test squashing with --dry-run first"

echo
echo "Demo complete! Test repository is in: $PWD"
echo "You can safely delete it with: rm -rf $PWD"
