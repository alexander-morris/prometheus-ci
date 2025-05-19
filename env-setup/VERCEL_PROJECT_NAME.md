# Vercel Project Name (VERCEL_PROJECT_NAME)

## Overview
The `VERCEL_PROJECT_NAME` variable allows you to specify a custom name for your Vercel project when it's created during the setup process. This affects the project's display name in the Vercel dashboard as well as its deployment URLs.

## Usage

Add to your `.env` file:

```
VERCEL_PROJECT_NAME=my-custom-project-name
```

## Default Behavior

If not specified, the tool automatically uses the repository name as the project name. For example, if your repository is named `my-website`, the Vercel project will also be named `my-website`.

## Naming Rules

When choosing a custom project name, follow these rules:

- Must be unique within your Vercel account/team
- Can only contain lowercase letters, numbers, and hyphens
- Cannot start or end with a hyphen
- Maximum length is 100 characters
- Should be URL-friendly (will be part of your deployment URLs)

## What This Affects

The project name impacts:

1. The name displayed in your Vercel dashboard
2. The default domain for your production deployment (`https://{project-name}.vercel.app`)
3. The URL pattern for branch deployments (`https://{project-name}-git-{branch}-{owner}.vercel.app`)
4. API references to your project

## Example URLs

For a project named `my-awesome-site`:

- Production URL: `https://my-awesome-site.vercel.app`
- Development branch URL: `https://my-awesome-site-git-development-username.vercel.app`
- Feature branch URL: `https://my-awesome-site-git-feature-username.vercel.app`

## Example Configuration

```
# Required variables
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token

# Custom Vercel project name
VERCEL_PROJECT_NAME=my-brand-website
```

## Notes and Limitations

- If the specified name is already taken, Vercel will automatically append a random suffix
- Changing the project name after creation requires manual intervention in the Vercel dashboard
- Project names are global across Vercel, so choose a distinctive name
- The project name cannot be changed through the API after creation

## Troubleshooting

If you encounter issues with your custom project name:

1. Verify it follows Vercel's naming rules
2. Check if the name is already taken in your Vercel account
3. If the name is invalid, the tool will fall back to using the repository name
4. For URL issues, check the actual project name in your Vercel dashboard

## Related Variables

- `VERCEL_TOKEN` - Required for Vercel authentication
- `HOSTING_TYPE=vercel` - Must be set to use Vercel (default if `VERCEL_TOKEN` is provided) 