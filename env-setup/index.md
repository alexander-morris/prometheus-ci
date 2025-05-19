# Environment Variable Documentation

This directory contains detailed documentation for all environment variables used in the Prometheus CI tool.

## Required Variables

These variables are essential for the basic functionality of the tool:

- [**GITHUB_TOKEN**](./GITHUB_TOKEN.md) - GitHub Personal Access Token for API access
- [**ORIGINAL_REPO_URL**](./ORIGINAL_REPO_URL.md) - URL of the repository to fork

## Hosting Provider Variables

At least one of these is required for deployments:

- [**VERCEL_TOKEN**](./VERCEL_TOKEN.md) - Authentication token for Vercel (preferred)
- [**NETLIFY_AUTH_TOKEN**](./NETLIFY_AUTH_TOKEN.md) - Authentication token for Netlify (alternative)

## Optional Configuration Variables

These variables allow you to customize the behavior of the tool:

- [**HOSTING_TYPE**](./HOSTING_TYPE.md) - Which hosting provider to use (`vercel` or `netlify`)
- [**SITE_TYPE**](./SITE_TYPE.md) - Type of site being deployed (auto-detected if not specified)
- [**CI_TYPE**](./CI_TYPE.md) - CI system to use (`github-actions`, `gitlab-ci`, etc.)
- [**TARGET_BRANCH**](./TARGET_BRANCH.md) - Branch to add CI configuration to (auto-detected if not specified)
- [**CREATE_DEV_BRANCH**](./CREATE_DEV_BRANCH.md) - Whether to create a development branch (`true`/`false`)
- [**ORGANIZATION**](./ORGANIZATION.md) - GitHub organization to fork to (uses personal account if not specified)

## Hosting-Specific Variables

### Vercel

- [**VERCEL_PROJECT_NAME**](./VERCEL_PROJECT_NAME.md) - Custom name for your Vercel project

### Netlify

- [**NETLIFY_SITE_NAME**](./NETLIFY_SITE_NAME.md) - Custom name for your Netlify site

## Quick Start Example

Here's a minimal configuration example:

```
# .env file
GITHUB_TOKEN=ghp_your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token
CREATE_DEV_BRANCH=true
```

## Advanced Configuration Example

Here's a more comprehensive configuration:

```
# .env file

# Required variables
GITHUB_TOKEN=ghp_your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo

# Hosting configuration
VERCEL_TOKEN=your_vercel_token
VERCEL_PROJECT_NAME=custom-project-name

# Optional configuration
CI_TYPE=github-actions
SITE_TYPE=jekyll
TARGET_BRANCH=main
CREATE_DEV_BRANCH=true
ORGANIZATION=your-organization
``` 