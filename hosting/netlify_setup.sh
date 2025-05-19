#!/bin/bash

# Exit on error
set -e

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found" >&2
  exit 1
fi

# Check for required environment variables
if [ -z "$NETLIFY_AUTH_TOKEN" ] || [ -z "$GITHUB_TOKEN" ] || [ -z "$FORKED_REPO" ] || [ -z "$FORKED_OWNER" ]; then
  echo "Error: Required environment variables not set" >&2
  echo "Please ensure NETLIFY_AUTH_TOKEN, GITHUB_TOKEN, FORKED_REPO, and FORKED_OWNER are set" >&2
  exit 1
fi

# Set site name (defaults to repo name if not specified)
SITE_NAME=${NETLIFY_SITE_NAME:-$FORKED_REPO}

echo "Setting up Netlify for repository $FORKED_OWNER/$FORKED_REPO..."

# Create a new Netlify site
echo "Creating Netlify site..."
NETLIFY_RESPONSE=$(curl -s -X POST \
  "https://api.netlify.com/api/v1/sites" \
  -H "Authorization: Bearer $NETLIFY_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$SITE_NAME\"}")

# Extract site ID and name
NETLIFY_SITE_ID=$(echo "$NETLIFY_RESPONSE" | jq -r '.id')
NETLIFY_SITE_NAME=$(echo "$NETLIFY_RESPONSE" | jq -r '.name')
NETLIFY_SITE_URL=$(echo "$NETLIFY_RESPONSE" | jq -r '.ssl_url')

if [[ "$NETLIFY_SITE_ID" == "null" || -z "$NETLIFY_SITE_ID" ]]; then
  echo "Error: Failed to create Netlify site" >&2
  echo "$NETLIFY_RESPONSE" >&2
  exit 1
fi

echo "Netlify site created:"
echo "  Site ID: $NETLIFY_SITE_ID"
echo "  Site Name: $NETLIFY_SITE_NAME"
echo "  Site URL: $NETLIFY_SITE_URL"

# Add GitHub repository secrets for Netlify deployment
echo "Adding GitHub repository secrets for Netlify deployment..."

# Get the public key for the repository
echo "Fetching repository public key for secret encryption..."
PUBLIC_KEY_RESPONSE=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/actions/secrets/public-key")

KEY_ID=$(echo "$PUBLIC_KEY_RESPONSE" | jq -r '.key_id')
PUBLIC_KEY=$(echo "$PUBLIC_KEY_RESPONSE" | jq -r '.key')

if [[ -z "$KEY_ID" || "$KEY_ID" == "null" ]]; then
  echo "Error: Failed to get repository public key" >&2
  echo "$PUBLIC_KEY_RESPONSE" >&2
  exit 1
fi

# Add NETLIFY_AUTH_TOKEN secret
echo "Adding NETLIFY_AUTH_TOKEN secret..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS base64 encoding (no -w option)
  ENCODED_TOKEN=$(echo -n "$NETLIFY_AUTH_TOKEN" | base64)
else
  # Linux base64 encoding
  ENCODED_TOKEN=$(echo -n "$NETLIFY_AUTH_TOKEN" | base64 -w 0)
fi

curl -s -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/actions/secrets/NETLIFY_AUTH_TOKEN" \
  -d "{
    \"encrypted_value\": \"$ENCODED_TOKEN\",
    \"key_id\": \"$KEY_ID\"
  }" > /dev/null

# Add NETLIFY_SITE_ID secret
echo "Adding NETLIFY_SITE_ID secret..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS base64 encoding (no -w option)
  ENCODED_SITE_ID=$(echo -n "$NETLIFY_SITE_ID" | base64)
else
  # Linux base64 encoding
  ENCODED_SITE_ID=$(echo -n "$NETLIFY_SITE_ID" | base64 -w 0)
fi

curl -s -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/actions/secrets/NETLIFY_SITE_ID" \
  -d "{
    \"encrypted_value\": \"$ENCODED_SITE_ID\",
    \"key_id\": \"$KEY_ID\"
  }" > /dev/null

echo "Netlify setup complete!"
echo "Your site will be available at: $NETLIFY_SITE_URL"
echo "Branch deployments will be available at: https://<branch-name>--$NETLIFY_SITE_NAME.netlify.app" 