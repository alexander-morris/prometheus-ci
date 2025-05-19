# Development Branch Creation (CREATE_DEV_BRANCH)

## Overview
The `CREATE_DEV_BRANCH` variable controls whether the tool automatically creates a development branch in the forked repository. This feature is useful for establishing a separate environment for development and testing before merging changes to the main branch.

## Valid Values

This is a boolean variable that accepts the following values:

- `true` - Create a development branch (default)
- `false` - Don't create a development branch

## Usage

Add to your `.env` file:

```
CREATE_DEV_BRANCH=true
```

## What This Does

When set to `true`, the tool will:

1. Fork the original repository
2. Add the CI configuration to the default branch
3. Create a new `development` branch from the default branch
4. Set up automatic deployments for the development branch

## Deployment URLs

Depending on your hosting provider, the development branch will be deployed to:

### Vercel
```
https://{repo-name}-git-development-{owner}.vercel.app
```

### Netlify
```
https://development--{repo-name}.netlify.app
```

## Use Cases

- **Feature Development**: Provide a stable development environment for testing new features
- **Continuous Integration**: Automatically test changes before merging to production
- **Review Environments**: Share development versions with stakeholders for feedback
- **Documentation**: Test documentation changes in an isolated environment

## Additional Information

- The development branch name is hard-coded as `development`
- The branch is created with the same content as the default branch
- Both the main branch and development branch will have CI/CD pipelines
- Any future pushes to the development branch will trigger automatic deployments

## Example Configuration

```
# Required variables
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token

# Enable development branch creation
CREATE_DEV_BRANCH=true
```

## Troubleshooting

If the development branch is not created:

1. Check that `CREATE_DEV_BRANCH` is set to `true`
2. Verify that your GitHub token has permission to create branches
3. Ensure the fork process completed successfully
4. Check if a development branch already exists in the repository 