# Hosting Provider Selection (HOSTING_TYPE)

## Overview
The `HOSTING_TYPE` variable specifies which hosting provider to use for deploying your forked repository. The tool supports automatic setup and configuration for multiple hosting providers, each with their own features for branch deployments and preview environments.

## Supported Values

- `vercel` - Vercel hosting (default)
- `netlify` - Netlify hosting

## Usage

Add to your `.env` file:

```
HOSTING_TYPE=vercel
```

## Provider Selection Logic

The tool selects a hosting provider based on the following logic:

1. If `VERCEL_TOKEN` is provided, Vercel is used by default
2. If only `NETLIFY_AUTH_TOKEN` is provided, Netlify is used
3. If both tokens are provided, Vercel is used by default unless `HOSTING_TYPE=netlify` is explicitly set
4. If neither token is provided, Vercel is set as the default but deployment will fail without credentials

## Provider Comparison

### Vercel

**Pros:**
- Fast global CDN
- Automatic preview deployments for all branches
- Seamless GitHub integration
- Optimized for Next.js and other modern frameworks
- Advanced deployment features (A/B testing, incremental static regeneration)

**Required Variable:** `VERCEL_TOKEN`

**URLs:**
- Production: `https://{repo-name}.vercel.app`
- Branch: `https://{repo-name}-git-{branch-name}-{owner}.vercel.app`

### Netlify

**Pros:**
- Intuitive UI
- Built-in form handling
- Excellent for static sites and Jamstack
- Branch deploys with easy URL structure
- Free SSL certificates

**Required Variable:** `NETLIFY_AUTH_TOKEN`

**URLs:**
- Production: `https://{repo-name}.netlify.app`
- Branch: `https://{branch-name}--{repo-name}.netlify.app`

## CI/CD Integration

The tool automatically selects the appropriate CI/CD configuration based on:
1. The selected hosting provider
2. The detected site type

For example:
- Jekyll site + Vercel: Uses Jekyll-specific Vercel configuration
- Jekyll site + Netlify: Uses Jekyll-specific Netlify configuration
- Generic site + Vercel: Uses standard Vercel configuration

## Example Configuration

### Vercel (Default)
```
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token
HOSTING_TYPE=vercel  # Optional, as Vercel is the default
```

### Netlify
```
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
NETLIFY_AUTH_TOKEN=your_netlify_token
HOSTING_TYPE=netlify
```

## Limitations

- Only one hosting provider can be selected per fork
- Changing the hosting provider after initial setup requires manual intervention
- Self-hosted options are not currently supported

## Related Variables

- `VERCEL_TOKEN` - For Vercel authentication
- `VERCEL_PROJECT_NAME` - Custom project name for Vercel (optional)
- `NETLIFY_AUTH_TOKEN` - For Netlify authentication
- `NETLIFY_SITE_NAME` - Custom site name for Netlify (optional) 