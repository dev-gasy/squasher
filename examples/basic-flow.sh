#!/usr/bin/env bash

# Basic Flow Example - Demonstrates squasher usage
# This script creates a temporary git repository to safely demonstrate squashing

set -e

echo "=== Squasher Basic Flow Example ==="
echo

# Create a temporary directory for the demo
DEMO_DIR="test-repo"
rm -rf "$DEMO_DIR"
mkdir "$DEMO_DIR"
cd "$DEMO_DIR"

echo "1. Creating a demo repository..."
git init --quiet
git config user.email "demo@example.com"
git config user.name "Demo User"

# Create initial commits on main branch
echo "2. Creating main branch with initial commits..."
echo "Initial content" > README.md
git add README.md
git commit -m "Initial commit" --quiet

echo "Version 1.0" > version.txt
git add version.txt
git commit -m "Add version file" --quiet

# Create and switch to feature branch
echo "3. Creating feature branch..."
git checkout -b feature/new-functionality --quiet

# Make several commits that we'll squash later
echo "4. Making multiple commits on feature branch..."
echo "## Features" >> README.md
git add README.md
git commit -m "Add features section to README" --quiet

echo "- Feature 1" >> README.md
git add README.md
git commit -m "Add feature 1" --quiet

echo "- Feature 2" >> README.md
git add README.md
git commit -m "Add feature 2" --quiet

echo "- Feature 3" >> README.md
git add README.md
git commit -m "Add feature 3" --quiet

echo "Version 1.1-dev" > version.txt
git add version.txt
git commit -m "Update version to 1.1-dev" --quiet

# Show current state
echo
echo "5. Current commit history:"
git log --oneline --graph --all

# Demonstrate dry-run
echo
echo "6. Preview squashing with dry-run:"
echo "   Running: squasher main --dry-run -m \"Feature: Add new functionality\""
../../squasher.sh main --dry-run -m "Feature: Add new functionality"

# Ask user if they want to proceed
echo
read -p "7. Proceed with actual squashing? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "8. Performing actual squash with backup:"
    echo "   Running: squasher main -m \"Feature: Add new functionality\" --backup --stats"
    ../../squasher.sh main -m "Feature: Add new functionality" --backup --stats
    
    echo
    echo "9. Final commit history:"
    git log --oneline --graph --all
    
    echo
    echo "10. Backup branches created:"
    git branch -a | grep backup || echo "No backup branches found"
else
    echo "Skipping actual squash operation."
fi

echo
echo "Demo complete! The test repository is in: $PWD"
echo "You can safely delete it with: rm -rf $PWD"
