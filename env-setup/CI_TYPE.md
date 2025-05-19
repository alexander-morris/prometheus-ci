# CI System Selection (CI_TYPE)

## Overview
The `CI_TYPE` variable specifies which Continuous Integration (CI) system to use for your forked repository. Different CI systems offer various features, interfaces, and integrations, allowing you to choose the one that best fits your workflow.

## Supported Values

- `github-actions` - GitHub Actions workflow (default)
- `gitlab-ci` - GitLab CI pipeline
- `circle-ci` - CircleCI config
- `travis-ci` - Travis CI config
- `jenkins` - Jenkins pipeline
- `azure-pipelines` - Azure DevOps Pipelines
- `bitbucket-pipelines` - Bitbucket Pipelines

## Usage

Add to your `.env` file:

```
CI_TYPE=github-actions
```

## CI System Details

### GitHub Actions (`github-actions`)

**Description:**
GitHub's native CI/CD solution integrated directly into repositories.

**Configuration File:** `.github/workflows/ci.yml`

**Best for:**
- GitHub repositories
- Simple to complex workflows
- Repositories that don't use other CI services

### GitLab CI (`gitlab-ci`)

**Description:**
GitLab's integrated CI/CD solution.

**Configuration File:** `.gitlab-ci.yml`

**Best for:**
- Projects that will be mirrored to GitLab
- Teams already using GitLab for other projects

### CircleCI (`circle-ci`)

**Description:**
Cloud-based CI/CD service with a focus on performance and customization.

**Configuration File:** `.circleci/config.yml`

**Best for:**
- Projects requiring complex workflows
- Teams already using CircleCI

### Travis CI (`travis-ci`)

**Description:**
Cloud-based CI service that integrates with GitHub.

**Configuration File:** `.travis.yml`

**Best for:**
- Simple CI needs
- Open source projects

### Jenkins (`jenkins`)

**Description:**
Self-hosted automation server for CI/CD.

**Configuration File:** `Jenkinsfile`

**Best for:**
- Teams with existing Jenkins infrastructure
- Projects requiring high customization

### Azure Pipelines (`azure-pipelines`)

**Description:**
Microsoft's CI/CD service that's part of Azure DevOps.

**Configuration File:** `azure-pipelines.yml`

**Best for:**
- Teams using Azure DevOps
- Microsoft-focused technology stacks

### Bitbucket Pipelines (`bitbucket-pipelines`)

**Description:**
Atlassian's integrated CI/CD service for Bitbucket.

**Configuration File:** `bitbucket-pipelines.yml`

**Best for:**
- Projects that will be mirrored to Bitbucket
- Teams using other Atlassian products

## Integration with Site Types

Each CI system is configured with appropriate settings based on the detected site type:

- **Jekyll sites:** Includes Ruby setup, Jekyll build commands
- **Generic sites:** Includes standard web project configuration

## Integration with Hosting Providers

The tool selects CI configurations that work well with your chosen hosting provider:

- **Vercel:** Optimized for Vercel deployments
- **Netlify:** Optimized for Netlify deployments

## Example Configuration

```
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token
CI_TYPE=github-actions
```

## Notes and Limitations

- Some CI systems may require additional setup outside this tool
- Not all CI systems integrate equally well with all hosting providers
- GitHub Actions is recommended for most use cases due to its native GitHub integration
- The tool does not currently support custom CI configuration templates

## Troubleshooting

If you encounter issues with CI setup:

1. Check that your chosen CI system is compatible with your repository structure
2. Verify that your GitHub token has sufficient permissions
3. For non-GitHub CI systems, you may need to set up additional integrations manually 