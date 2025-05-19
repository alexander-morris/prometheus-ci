# Vercel Authentication Token (VERCEL_TOKEN)

## Overview
A Vercel Authentication Token is required for the tool to interact with the Vercel API. This token enables:
- Creating new Vercel projects
- Configuring project settings
- Deploying sites from GitHub repositories
- Setting up branch deployments
- Managing project environments

## Prerequisites
- A Vercel account (you can sign up at [vercel.com](https://vercel.com/signup))
- GitHub account connected to your Vercel account

## How to Generate a Token

1. Log in to your [Vercel account](https://vercel.com/dashboard)
2. Click on your profile picture in the top-right corner
3. Select **Settings** from the dropdown menu
4. Navigate to the **Tokens** tab in the left sidebar
5. Click **Create** to create a new token
6. Enter a descriptive name for your token (e.g., "Prometheus CI Tool")
7. Set the expiration date (or choose "No expiration" if needed)
8. Select the appropriate scope:
   - For full access: **Full Account**
   - For limited access: **Restricted**
9. Click **Create Token**
10. **IMPORTANT**: Copy the token immediately as it will only be shown once

![Vercel Token Creation](https://vercel.com/docs-proxy/static/documentation/guides/deploy-hooks/token-creation.png)

## Adding to Your Environment

Add the token to your `.env` file:

```
VERCEL_TOKEN=your_vercel_token_here
```

Replace `your_vercel_token_here` with your actual Vercel token.

## Required Related Variables

When using the Vercel token, the tool will automatically:
1. Retrieve your Vercel organization ID
2. Create a new project with the appropriate name
3. Configure the project settings for branch deployments

Optionally, you can specify a custom project name:

```
VERCEL_PROJECT_NAME=your-custom-project-name
```

If not specified, the repository name will be used.

## Security Considerations

- Never commit your token to a public repository
- Use tokens with appropriate expiration dates
- Consider using restricted tokens for production environments
- Revoke tokens when they are no longer needed
- Rotate tokens regularly

## Troubleshooting

If you encounter errors related to Vercel deployment:

1. Verify the token is valid and not expired
2. Check that your GitHub account is connected to Vercel
3. Ensure the Vercel token has sufficient permissions
4. Check for any organization-level restrictions
5. Confirm API rate limits haven't been exceeded

## References

- [Vercel Authentication documentation](https://vercel.com/docs/rest-api#authentication)
- [Vercel API documentation](https://vercel.com/docs/api)
- [Vercel project configuration](https://vercel.com/docs/concepts/projects/project-configuration) 