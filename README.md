# GitHub Repository Forker with CI Pipeline and Development Previews

This tool allows you to programmatically fork a GitHub repository, add a CI pipeline, and set up automatic branch deployments with public URLs for each branch.

## Prerequisites

- `bash` shell
- `curl` for API requests
- `jq` for JSON parsing
- GitHub Personal Access Token with `repo` scope
- Vercel or Netlify account with API token

## Features

- Fork any GitHub repository with a single command
- Automatically detect repository type and configuration
- Add CI configuration for multiple CI platforms
- Set up automatic deployments for all branches
- Create development URLs for preview environments
- Specialized support for Jekyll sites

## Setup

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/prometheus-ci.git
   cd prometheus-ci
   ```

2. Copy the sample environment file and update it with your tokens and repository details:
   ```
   cp env.sample .env
   ```

3. Edit the `.env` file with your details. For detailed documentation on all environment variables, see the [env-setup](./env-setup/index.md) directory.
   ```
   # Required
   GITHUB_TOKEN=your_github_personal_access_token
   ORIGINAL_REPO_URL=https://github.com/owner/repo
   
   # For Vercel deployments (preferred)
   VERCEL_TOKEN=your_vercel_auth_token
   
   # For Netlify deployments (alternative)
   # NETLIFY_AUTH_TOKEN=your_netlify_auth_token
   
   # Optional configurations
   CREATE_DEV_BRANCH=true
   ```

4. Make the scripts executable:
   ```
   chmod +x fork_and_add_ci.sh hosting/netlify_setup.sh hosting/vercel_setup.sh repo_parser.sh
   ```

## Usage

Run the script to fork the repository and set up CI with branch deployments:

```
./fork_and_add_ci.sh
```

The script will:
1. Parse the repository URL and detect repository settings
2. Fork the specified repository to your GitHub account
3. Create a CI configuration file in the forked repository based on the detected site type
4. Set up Vercel or Netlify for automatic branch-based deployments
5. Optionally create a development branch
6. Display URLs for both production and development environments

## Automatic Detection

The tool automatically detects:

- Repository owner and name from the URL
- Repository default branch
- Site type (Jekyll or generic)

These settings can be overridden in the `.env` file if needed.

## Hosting Provider Selection

The tool selects a hosting provider based on the following logic:

1. If `VERCEL_TOKEN` is provided, Vercel is used (recommended)
2. If only `NETLIFY_AUTH_TOKEN` is provided, Netlify is used
3. If both are provided, Vercel is used by default unless `HOSTING_TYPE=netlify` is explicitly set
4. If neither is provided, Vercel is used as the default but deployment will fail without credentials

## Site Types

The tool supports different site types with specialized CI configurations:

- `generic` - Standard web application (auto-detected)
- `jekyll` - Jekyll static site (auto-detected)

## Hosting Options

The tool supports multiple hosting providers with automatic branch deployments:

- `vercel` - Vercel hosting (default)
  - Production URL: `https://<site-name>.vercel.app`
  - Branch URLs: `https://<site-name>-git-<branch-name>-<owner>.vercel.app`

- `netlify` - Netlify hosting (alternative)
  - Production URL: `https://<site-name>.netlify.app`
  - Branch URLs: `https://<branch-name>--<site-name>.netlify.app`

## Supported CI Systems

The tool supports multiple CI systems through adapters:

```
./ci_adapters.sh
```

Available CI adapters:
- `github-actions` - GitHub Actions workflow
- `gitlab-ci` - GitLab CI pipeline
- `circle-ci` - CircleCI config
- `travis-ci` - Travis CI config
- `jenkins` - Jenkins pipeline
- `azure-pipelines` - Azure DevOps Pipelines
- `bitbucket-pipelines` - Bitbucket Pipelines

## Example: Setting up a Jekyll site with Vercel branch deployments

```
# .env file configuration
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/jekyll/jekyll-now
VERCEL_TOKEN=your_vercel_token
CREATE_DEV_BRANCH=true
```

After running `./fork_and_add_ci.sh`, you'll have:
- A forked Jekyll site with CI configured (auto-detected)
- Automatic Vercel deployments for all branches
- A development branch with its own URL

## Customization

You can customize the CI configurations by editing the template files in the `ci_adapters/` directory:

- `ci_adapters/github_actions.yml` - Standard GitHub Actions workflow
- `ci_adapters/github_actions_jekyll.yml` - Jekyll-specific workflow with Vercel deployments
- `ci_adapters/github_actions_vercel.yml` - Generic workflow with Vercel deployments
- `ci_adapters/github_actions_netlify.yml` - Generic workflow with Netlify deployments
- `ci_adapters/github_actions_jekyll_netlify.yml` - Jekyll-specific workflow with Netlify deployments
- Other CI templates...

## Error Handling

The script includes robust error handling for:
- Missing environment variables
- Invalid repository URL
- Failed repository type detection
- Failed repository fork
- Failed CI configuration file creation
- Failed hosting setup

## License

MIT 