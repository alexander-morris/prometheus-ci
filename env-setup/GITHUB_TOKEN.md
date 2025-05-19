# GitHub Personal Access Token (GITHUB_TOKEN)

## Overview
A GitHub Personal Access Token (PAT) is required for this tool to interact with the GitHub API. It allows the tool to:
- Fork repositories
- Create and modify files in repositories
- Create branches
- Manage repository secrets

## Required Permissions
Your GitHub token needs the following scopes:
- `repo` (Full control of private repositories)
  - This includes access to code, commit statuses, repository invitations, collaborators, and deployment statuses

## How to Generate a Token

1. Go to [GitHub Personal Access Tokens page](https://github.com/settings/tokens)
2. Click on **Generate new token** > **Generate new token (classic)**
3. Give your token a descriptive name like "Prometheus CI Tool"
4. Set the expiration as needed (recommended: 90 days)
5. Select the following scopes:
   - **repo** (all checkboxes under repo)
   - **workflow** (if you need to manage GitHub Actions workflows)
6. Click **Generate token**
7. **IMPORTANT**: Copy and save the token immediately. GitHub will only show it once.

![GitHub Token Creation](https://docs.github.com/assets/cb-34573/images/help/settings/personal_access_token.png)

## Adding to Your Environment

Add the token to your `.env` file:

```
GITHUB_TOKEN=ghp_YourTokenHere123456789abcdefghijklmno
```

Replace `ghp_YourTokenHere123456789abcdefghijklmno` with your actual token.

## Security Considerations

- Never commit your token to a public repository
- Set an appropriate expiration date
- Use a token with the minimal permissions needed
- Rotate tokens regularly
- If a token is compromised, revoke it immediately on GitHub

## Troubleshooting

If you encounter errors like "Bad credentials" or "Resource not accessible by integration", check:
1. The token is valid and not expired
2. The token has the required permissions
3. You haven't exceeded GitHub's API rate limits

## References

- [GitHub documentation on creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub API rate limits](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting) 