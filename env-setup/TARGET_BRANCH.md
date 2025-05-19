# Target Branch Configuration (TARGET_BRANCH)

## Overview
The `TARGET_BRANCH` variable specifies which branch in the forked repository should receive the CI configuration. This determines where the CI/CD pipeline will be initially set up and from which branch other branches (like development) will be created.

## Usage

Add to your `.env` file:

```
TARGET_BRANCH=main
```

## Default Behavior

If not specified, the tool automatically detects the default branch of the original repository (typically `main` or `master`) and uses that as the target branch.

## Common Values

- `main` - Modern default branch name (GitHub default since October 2020)
- `master` - Traditional default branch name
- `develop` - Common name for development branches in Git Flow workflows
- Custom branch names specific to your project

## What This Affects

Setting the target branch impacts:

1. Where the CI configuration file is added
2. Which branch is used as the source for creating the development branch (if enabled)
3. The branch that will be considered the "production" branch for deployments
4. The trigger conditions for CI workflows

## Automatic Detection

The tool uses the GitHub API to detect the default branch of the repository you're forking. This detection:

1. Queries the repository metadata
2. Identifies the designated default branch
3. Uses this as the target branch unless manually overridden

## Use Cases for Overriding

You might want to override the automatically detected branch when:

1. You want to set up CI on a branch other than the default branch
2. The repository has a non-standard branch structure
3. You want to test CI configurations without affecting the default branch
4. Your fork will have a different branch structure than the original repository

## Example Configuration

### Using Automatic Detection (Recommended)
```
# Target branch will be auto-detected from repository
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
```

### Manual Override
```
# Explicitly set target branch
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
TARGET_BRANCH=develop
```

## Notes and Limitations

- The target branch must exist in the repository after forking
- Changing the target branch after initial setup requires manual intervention
- Branch protection rules from the original repository may be carried over to the fork
- If the specified branch doesn't exist, the tool will fail with an error

## Related Features

- `CREATE_DEV_BRANCH=true` will create a development branch from the target branch
- CI configurations will typically be set to trigger on both the target branch and development branches 