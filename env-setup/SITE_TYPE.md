# Site Type Configuration (SITE_TYPE)

## Overview
The `SITE_TYPE` variable specifies the type of website or application in the repository. This helps the tool select the appropriate CI/CD configuration, build commands, and deployment settings for your project.

## Supported Values

- `generic` - Standard web application (auto-detected, default)
- `jekyll` - Jekyll static site (auto-detected)

## Usage

Add to your `.env` file:

```
SITE_TYPE=jekyll
```

## Automatic Detection

In most cases, you don't need to set this variable manually. The tool automatically detects the site type based on:

1. Presence of specific files (e.g., `_config.yml` for Jekyll)
2. Repository language information (e.g., Ruby for Jekyll)
3. Project structure

The auto-detection can be overridden by explicitly setting this variable.

## Site Type Details

### Generic (`generic`)

Standard web application configuration, typically for:
- Node.js applications
- Single Page Applications (React, Vue, Angular)
- Static HTML/CSS/JS sites
- Other web projects

**Build Commands:**
- `npm run build` (default)
- Output directory: `build/` or `dist/`

### Jekyll (`jekyll`)

Configuration specifically for Jekyll static sites:
- Ruby-based static site generator
- Markdown content
- Liquid templates

**Build Commands:**
- `bundle exec jekyll build`
- Output directory: `_site/`

## Integration with Hosting Providers

Each site type is configured with specific settings for each hosting provider:

### Jekyll + Vercel
- Uses Ruby setup
- Configures Jekyll build commands
- Sets appropriate output directory

### Jekyll + Netlify
- Uses Ruby setup
- Configures Jekyll build commands
- Sets Netlify-specific build settings

### Generic + Vercel/Netlify
- Uses standard build commands
- Assumes Node.js-based workflow

## Example Configuration

### Explicit Jekyll Configuration
```
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token
SITE_TYPE=jekyll
```

### Relying on Auto-Detection (Recommended)
```
GITHUB_TOKEN=your_github_token
ORIGINAL_REPO_URL=https://github.com/owner/repo
VERCEL_TOKEN=your_vercel_token
# SITE_TYPE is automatically detected
```

## Why Site Type Matters

The site type affects:
1. Which CI/CD template is used
2. Build commands and environment setup
3. Output directory configuration
4. Environment variables for the build process
5. Caching strategies

## Troubleshooting

If automatic detection doesn't correctly identify your site type:

1. Explicitly set the `SITE_TYPE` variable
2. Check that your repository has the expected structure and files
3. If your site type is not supported, use `generic` and customize the CI/CD configuration manually after forking

## Future Support

Additional site types planned for future support:
- Next.js
- Hugo
- Gatsby
- WordPress
- Custom frameworks

If your site type is not listed, use `generic` and the tool will apply standard web configuration. 