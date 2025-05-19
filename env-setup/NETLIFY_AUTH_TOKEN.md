# Netlify Authentication Token (NETLIFY_AUTH_TOKEN)

## Overview
A Netlify Authentication Token is required for the tool to interact with the Netlify API. This token enables:
- Creating new Netlify sites
- Configuring site settings
- Setting up continuous deployment
- Managing deploy contexts for branch deployments
- Setting up preview environments

## Prerequisites
- A Netlify account (you can sign up at [netlify.com](https://app.netlify.com/signup))
- GitHub account integrated with Netlify (for CI/CD)

## How to Generate a Token

1. Log in to your [Netlify account](https://app.netlify.com/)
2. Click on your avatar in the top-right corner
3. Select **User settings** from the dropdown menu
4. Navigate to the **Applications** tab
5. Scroll down to the **Personal access tokens** section
6. Click **New access token**
7. Enter a descriptive name for your token (e.g., "Prometheus CI Tool")
8. Click **Generate token**
9. **IMPORTANT**: Copy your token immediately as it will only be shown once

![Netlify Token Creation](https://cdn.netlify.com/4d5a117b-a363-4ff6-8dec-6d95464d1d0e/7d0574c3-0a39-4afb-b6aa-fb6b5cdedc9b/personal-access-token.png)

## Adding to Your Environment

Add the token to your `.env` file:

```
NETLIFY_AUTH_TOKEN=your_netlify_auth_token_here
```

Replace `your_netlify_auth_token_here` with your actual Netlify token.

## Required Related Variables

When using the Netlify token, the tool will automatically:
1. Create a new Netlify site
2. Configure the site settings for branch deployments
3. Set up the repository for continuous deployment

Optionally, you can specify a custom site name:

```
NETLIFY_SITE_NAME=your-custom-site-name
```

If not specified, the repository name will be used.

## Security Considerations

- Never commit your token to a public repository
- Netlify Personal Access Tokens do not expire automatically, so manage them carefully
- Remove tokens when they're no longer needed
- Create separate tokens for different projects or tools
- Limit token scope when possible

## Troubleshooting

If you encounter errors related to Netlify deployment:

1. Verify the token is valid
2. Check that your Netlify account has sufficient permissions
3. Verify your Netlify account has sufficient resources/sites available
4. Check if you've reached any Netlify API rate limits
5. Ensure the build settings are compatible with your site type

## References

- [Netlify Authentication documentation](https://docs.netlify.com/api/get-started/#authentication)
- [Netlify API documentation](https://docs.netlify.com/api/get-started/)
- [Netlify personal access tokens](https://docs.netlify.com/api/get-started/#personal-access-tokens)
- [Netlify site configuration](https://docs.netlify.com/configure-builds/get-started/) 