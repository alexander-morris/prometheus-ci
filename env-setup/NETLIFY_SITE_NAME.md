# Netlify Site Name (NETLIFY_SITE_NAME)

## Overview
The `NETLIFY_SITE_NAME` variable allows you to specify a custom name for your Netlify site when it's created during the setup process. This affects the site's display name in the Netlify dashboard as well as its deployment URLs.

## Usage

Add to your `.env` file:

```
NETLIFY_SITE_NAME=my-custom-site-name
```

## Default Behavior

If not specified, the tool automatically uses the repository name as the site name. For example, if your repository is named `my-website`, the Netlify site will also be named `my-website`.

## Naming Rules

When choosing a custom site name, follow these rules:

- Must be unique across all of Netlify (not just your account)
- Can only contain lowercase letters, numbers, and hyphens
- Cannot start or end with a hyphen
- Maximum length is 63 characters
- Should be URL-friendly (will be part of your deployment URLs)

## What This Affects

The site name impacts:

1. The name displayed in your Netlify dashboard
2. The default domain for your production deployment (`https://{site-name}.netlify.app`)
3. The URL pattern for branch deployments (`https://{branch-name}--{site-name}.netlify.app`)
4. API references to your site

## Example URLs

For a site named `my-awesome-site`:

- Production URL: `https://my-awesome-site.netlify.app`
- Development branch URL: `https://development--my-awesome-site.netlify.app`
- Feature branch URL: `https://feature-branch--my-awesome-site.netlify.app`

## Example Configuration

```
# Required variables
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
NETLIFY_AUTH_TOKEN=your_netlify_token
HOSTING_TYPE=netlify

# Custom Netlify site name
NETLIFY_SITE_NAME=my-brand-website
```

## Notes and Limitations

- If the specified name is already taken, Netlify will automatically generate a random name
- The name must be globally unique across all Netlify sites, not just within your account
- Once set, changing a site name requires manual intervention in the Netlify dashboard
- Custom domains can be added later through the Netlify dashboard

## Troubleshooting

If you encounter issues with your custom site name:

1. Verify it follows Netlify's naming rules
2. Check if the name is already taken by another Netlify site
3. If the name is invalid or taken, the tool will fall back to Netlify's auto-generated name
4. For URL issues, check the actual site name in your Netlify dashboard

## Related Variables

- `NETLIFY_AUTH_TOKEN` - Required for Netlify authentication
- `HOSTING_TYPE=netlify` - Must be set to use Netlify if `VERCEL_TOKEN` is also provided 