# Squasher Examples

This directory contains example scripts demonstrating various uses of the squasher tool.

## Available Examples

### 1. basic-flow.sh
Demonstrates the basic workflow of using squasher:
- Creates a demo repository
- Makes multiple commits on a feature branch
- Shows dry-run mode
- Performs actual squashing with backup and stats
- Shows the final result

**Run it:**
```bash
./basic-flow.sh
```

### 2. undo-demo.sh
Shows how to recover from a squash operation:
- Demonstrates backup branch recovery
- Shows git reflog recovery method
- Provides best practices for safe squashing

**Run it:**
```bash
./undo-demo.sh
```

### 3. advanced-usage.sh
Demonstrates advanced features and edge cases:
- Verbose mode with statistics
- Quiet mode for automation
- Dry-run with various options
- Interactive mode
- Error handling examples

**Run it:**
```bash
./advanced-usage.sh
```

## Notes

- All examples create temporary repositories that are safe to experiment with
- The scripts clean up after themselves
- No changes are made to your actual git repositories
- Examples assume squasher is installed in the parent directory

## Learning Path

1. Start with `basic-flow.sh` to understand the fundamental usage
2. Run `undo-demo.sh` to learn about recovery options
3. Explore `advanced-usage.sh` for more complex scenarios

## Tips

- Always use `--dry-run` first when learning
- The `--backup` option is recommended for important work
- Use `--stats` to see what changed after squashing
- Check the parent directory's README for full documentation
