# Repository URL (ORIGINAL_REPO_URL)

## Overview
The `ORIGINAL_REPO_URL` variable specifies the GitHub repository that you want to fork and add CI/CD pipelines to. This is the source repository that will be cloned and configured with automated deployments.

## Supported Formats

The tool accepts repository URLs in multiple formats:

1. **HTTPS URL** (recommended for most users):
   ```
   ORIGINAL_REPO_URL=https://github.com/owner/repo
   ```

2. **SSH URL** (for users with SSH GitHub authentication):
   ```
   ORIGINAL_REPO_URL=git@github.com:owner/repo.git
   ```

3. **Short format** (owner/repo pattern):
   ```
   ORIGINAL_REPO_URL=owner/repo
   ```

## Examples

Here are some valid examples:

```
# Jekyll website
ORIGINAL_REPO_URL=https://github.com/jekyll/jekyll-now

# React application
ORIGINAL_REPO_URL=facebook/create-react-app

# Any public GitHub repository
ORIGINAL_REPO_URL=https://github.com/username/repository-name
```

## Repository Access Requirements

- **Public repositories**: Work without any additional configuration
- **Private repositories**: Require a GitHub token with appropriate access permissions

## Automatic Detection

When you provide a repository URL, the tool automatically detects:

1. The repository owner and name
2. The default branch (main, master, etc.)
3. The type of project (Jekyll, Node.js, etc.)
4. The appropriate CI configuration

## Legacy Configuration

For backward compatibility, you can also specify the repository owner and name separately:

```
ORIGINAL_OWNER=owner
ORIGINAL_REPO=repo
```

However, using `ORIGINAL_REPO_URL` is recommended as it provides better automatic detection.

## Troubleshooting

If you encounter issues with the repository URL:

1. **Invalid URL format**: Ensure the URL follows one of the supported formats
2. **Repository not found**: Verify the repository exists and is spelled correctly
3. **Access denied**: Check if your GitHub token has permission to access the repository
4. **Detection issues**: If automatic detection fails, you can override settings with explicit variables:
   ```
   SITE_TYPE=jekyll
   TARGET_BRANCH=main
   ```

## Notes

- The tool only supports GitHub repositories currently
- Self-hosted GitHub Enterprise instances are not supported
- Repositories from other git providers (GitLab, Bitbucket, etc.) are not supported 