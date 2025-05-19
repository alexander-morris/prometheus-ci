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
if [ -z "$VERCEL_TOKEN" ] || [ -z "$GITHUB_TOKEN" ] || [ -z "$FORKED_REPO" ] || [ -z "$FORKED_OWNER" ]; then
  echo "Error: Required environment variables not set" >&2
  echo "Please ensure VERCEL_TOKEN, GITHUB_TOKEN, FORKED_REPO, and FORKED_OWNER are set" >&2
  exit 1
fi

# Set project name (defaults to repo name if not specified)
PROJECT_NAME=${VERCEL_PROJECT_NAME:-$FORKED_REPO}

echo "Setting up Vercel for repository $FORKED_OWNER/$FORKED_REPO..."

# Get Vercel user info for org ID
echo "Getting Vercel account information..."
VERCEL_USER_INFO=$(curl -s \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/user")

VERCEL_ORG_ID=$(echo "$VERCEL_USER_INFO" | jq -r '.user.id')

if [ -z "$VERCEL_ORG_ID" ] || [ "$VERCEL_ORG_ID" == "null" ]; then
  echo "Error: Failed to get Vercel organization ID" >&2
  echo "$VERCEL_USER_INFO" >&2
  exit 1
fi

echo "Vercel Organization ID: $VERCEL_ORG_ID"

# Create a new Vercel project
echo "Creating Vercel project..."
VERCEL_RESPONSE=$(curl -s -X POST \
  "https://api.vercel.com/v9/projects" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"$PROJECT_NAME\",
    \"framework\": \"$([ "$SITE_TYPE" = "jekyll" ] && echo "jekyll" || echo "other")\",
    \"gitRepository\": {
      \"type\": \"github\",
      \"repo\": \"$FORKED_OWNER/$FORKED_REPO\"
    }
  }")

# Extract project ID and name
VERCEL_PROJECT_ID=$(echo "$VERCEL_RESPONSE" | jq -r '.id')
VERCEL_PROJECT_NAME=$(echo "$VERCEL_RESPONSE" | jq -r '.name')
VERCEL_PROJECT_URL=$(echo "$VERCEL_RESPONSE" | jq -r '.alias[0]')

if [[ "$VERCEL_PROJECT_ID" == "null" || -z "$VERCEL_PROJECT_ID" ]]; then
  echo "Error: Failed to create Vercel project" >&2
  echo "$VERCEL_RESPONSE" >&2
  exit 1
fi

echo "Vercel project created:"
echo "  Project ID: $VERCEL_PROJECT_ID"
echo "  Project Name: $VERCEL_PROJECT_NAME"
echo "  Project URL: $VERCEL_PROJECT_URL"

# Configure project settings for branch deployments
echo "Configuring branch deployment settings..."
curl -s -X PATCH \
  "https://api.vercel.com/v9/projects/$VERCEL_PROJECT_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"buildCommand\": \"$([ "$SITE_TYPE" = "jekyll" ] && echo "bundle exec jekyll build" || echo "npm run build")\",
    \"outputDirectory\": \"$([ "$SITE_TYPE" = "jekyll" ] && echo "_site" || echo "build")\",
    \"ignoreCommand\": \"git diff --quiet HEAD^ HEAD -- $([ "$SITE_TYPE" = "jekyll" ] && echo "." || echo "src/ public/")\",
    \"devCommand\": \"$([ "$SITE_TYPE" = "jekyll" ] && echo "bundle exec jekyll serve" || echo "npm run dev")\"
  }" > /dev/null

# Add GitHub repository secrets for Vercel deployment
echo "Adding GitHub repository secrets for Vercel deployment..."

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

# Add VERCEL_TOKEN secret
echo "Adding VERCEL_TOKEN secret..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS base64 encoding (no -w option)
  ENCODED_TOKEN=$(echo -n "$VERCEL_TOKEN" | base64)
else
  # Linux base64 encoding
  ENCODED_TOKEN=$(echo -n "$VERCEL_TOKEN" | base64 -w 0)
fi

curl -s -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/actions/secrets/VERCEL_TOKEN" \
  -d "{
    \"encrypted_value\": \"$ENCODED_TOKEN\",
    \"key_id\": \"$KEY_ID\"
  }" > /dev/null

# Add VERCEL_ORG_ID secret
echo "Adding VERCEL_ORG_ID secret..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS base64 encoding (no -w option)
  ENCODED_ORG_ID=$(echo -n "$VERCEL_ORG_ID" | base64)
else
  # Linux base64 encoding
  ENCODED_ORG_ID=$(echo -n "$VERCEL_ORG_ID" | base64 -w 0)
fi

curl -s -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/actions/secrets/VERCEL_ORG_ID" \
  -d "{
    \"encrypted_value\": \"$ENCODED_ORG_ID\",
    \"key_id\": \"$KEY_ID\"
  }" > /dev/null

# Add VERCEL_PROJECT_ID secret
echo "Adding VERCEL_PROJECT_ID secret..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS base64 encoding (no -w option)
  ENCODED_PROJECT_ID=$(echo -n "$VERCEL_PROJECT_ID" | base64)
else
  # Linux base64 encoding
  ENCODED_PROJECT_ID=$(echo -n "$VERCEL_PROJECT_ID" | base64 -w 0)
fi

curl -s -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/actions/secrets/VERCEL_PROJECT_ID" \
  -d "{
    \"encrypted_value\": \"$ENCODED_PROJECT_ID\",
    \"key_id\": \"$KEY_ID\"
  }" > /dev/null

echo "Vercel setup complete!"
echo "Your production site will be available at: https://$VERCEL_PROJECT_NAME.vercel.app"
echo "Branch deployments will be available at: https://$VERCEL_PROJECT_NAME-git-{branch-name}-$FORKED_OWNER.vercel.app" 