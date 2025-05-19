# GitHub Organization (ORGANIZATION)

## Overview
The `ORGANIZATION` variable allows you to specify a GitHub organization to fork the repository to, instead of forking it to your personal account. This is useful for team projects or when you want the forked repository to belong to an organization you manage.

## Usage

Add to your `.env` file:

```
ORGANIZATION=your-organization-name
```

## Default Behavior

If not specified, the tool will fork the repository to your personal GitHub account (the account associated with your `GITHUB_TOKEN`).

## Requirements

To fork to an organization:

1. Your GitHub token must have appropriate permissions for the organization
2. You must be a member of the organization with permission to create repositories
3. The organization must allow repository forking

## What This Affects

Setting the organization impacts:

1. The ownership of the forked repository
2. The URL of the forked repository (`https://github.com/{organization}/{repo}`)
3. Branch protection and permission settings that may be specific to the organization
4. Deployment URLs for Vercel/Netlify that include the owner name

## Example Configuration

```
# Required variables
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token

# Fork to organization instead of personal account
ORGANIZATION=my-awesome-company
```

## Common Use Cases

- Forking to a team or company organization
- Creating a fork under a project-specific organization
- Maintaining organizational ownership of derived projects
- Ensuring team access to the forked repository

## Permissions and Access

When forking to an organization:

1. Repository visibility will match the source repository by default
2. Team access controls from the organization will apply
3. GitHub token must have the `admin:org` scope to access some organization features
4. Branch protection rules may be automatically applied based on organization settings

## Troubleshooting

If you encounter issues forking to an organization:

1. Verify your GitHub token has sufficient permissions for the organization
2. Check that you have the appropriate role in the organization
3. Ensure the organization name is spelled correctly
4. Confirm the organization allows new repository creation by members

## Related Variables

- `GITHUB_TOKEN` - Must have appropriate organization permissions
- `ORIGINAL_REPO_URL` - The repository to fork 