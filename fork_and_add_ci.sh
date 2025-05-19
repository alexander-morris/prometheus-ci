#!/bin/bash

# Exit on error
set -e

# Load CI adapters helper functions
source ./ci_adapters.sh

# Load repo parser helper functions
source ./repo_parser.sh

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Error: .env file not found" >&2
  exit 1
fi

# Check required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GitHub token not set in .env file" >&2
  echo "Please ensure GITHUB_TOKEN is set" >&2
  exit 1
fi

# Determine hosting provider based on available tokens
if [ -n "$VERCEL_TOKEN" ]; then
  # Use Vercel if token is provided
  HOSTING_TYPE="vercel"
elif [ -n "$NETLIFY_AUTH_TOKEN" ]; then
  # Use Netlify if only Netlify token is provided
  HOSTING_TYPE="netlify"
else
  # Default to Vercel even though setup will fail later without token
  HOSTING_TYPE=${HOSTING_TYPE:-vercel}
  echo "Warning: No hosting provider tokens found. Defaulting to $HOSTING_TYPE but deployment will fail without credentials."
fi

# Ensure setup scripts exist
if [[ "$HOSTING_TYPE" == "vercel" && ! -f "hosting/vercel_setup.sh" ]]; then
  echo "Error: Vercel setup script not found" >&2
  exit 1
elif [[ "$HOSTING_TYPE" == "netlify" && ! -f "hosting/netlify_setup.sh" ]]; then
  echo "Error: Netlify setup script not found" >&2
  exit 1
fi

# Check if we have a repo URL or owner/repo combination
if [ -n "$ORIGINAL_REPO_URL" ]; then
  # Extract owner and repo from URL
  REPO_INFO=$(parse_github_url "$ORIGINAL_REPO_URL")
  if [ $? -ne 0 ]; then
    echo "Error: Failed to parse repository URL" >&2
    exit 1
  fi
  
  ORIGINAL_OWNER=$(echo "$REPO_INFO" | cut -d'|' -f1)
  ORIGINAL_REPO=$(echo "$REPO_INFO" | cut -d'|' -f2)
  
  # Detect repository type and default branch
  echo "Detecting repository type and settings..."
  REPO_SETTINGS=$(detect_repo_type "$ORIGINAL_OWNER" "$ORIGINAL_REPO")
  DETECTED_SITE_TYPE=$(echo "$REPO_SETTINGS" | cut -d'|' -f1)
  DETECTED_BRANCH=$(echo "$REPO_SETTINGS" | cut -d'|' -f2)
  
  # Use detected values unless overridden
  SITE_TYPE=${SITE_TYPE:-$DETECTED_SITE_TYPE}
  TARGET_BRANCH=${TARGET_BRANCH:-$DETECTED_BRANCH}
  
  echo "Detected repository type: $DETECTED_SITE_TYPE"
  echo "Detected default branch: $DETECTED_BRANCH"
elif [ -n "$ORIGINAL_OWNER" ] && [ -n "$ORIGINAL_REPO" ]; then
  # Using legacy configuration with separate owner/repo fields
  echo "Using provided owner and repository name"
  
  # Detect repository type and default branch
  echo "Detecting repository type and settings..."
  REPO_SETTINGS=$(detect_repo_type "$ORIGINAL_OWNER" "$ORIGINAL_REPO")
  DETECTED_SITE_TYPE=$(echo "$REPO_SETTINGS" | cut -d'|' -f1)
  DETECTED_BRANCH=$(echo "$REPO_SETTINGS" | cut -d'|' -f2)
  
  # Use detected values unless overridden
  SITE_TYPE=${SITE_TYPE:-$DETECTED_SITE_TYPE}
  TARGET_BRANCH=${TARGET_BRANCH:-$DETECTED_BRANCH}
  
  echo "Detected repository type: $DETECTED_SITE_TYPE"
  echo "Detected default branch: $DETECTED_BRANCH"
else
  echo "Error: No repository information provided" >&2
  echo "Please set either ORIGINAL_REPO_URL or both ORIGINAL_OWNER and ORIGINAL_REPO in .env file" >&2
  exit 1
fi

# Use provided values or defaults
CI_TYPE=${CI_TYPE:-github-actions}

echo "Preparing to fork $ORIGINAL_OWNER/$ORIGINAL_REPO with $CI_TYPE CI pipeline..."
echo "Site type: $SITE_TYPE"
echo "Hosting: $HOSTING_TYPE"
echo "Target branch: $TARGET_BRANCH"

# Validate CI type and get template
CI_TEMPLATE_INFO=$(get_ci_template "$CI_TYPE" "" "$TARGET_BRANCH" "$SITE_TYPE" "$HOSTING_TYPE")
if [ $? -ne 0 ]; then
  echo "Error: Invalid CI_TYPE or SITE_TYPE specified" >&2
  list_ci_adapters
  exit 1
fi

# Extract target file and template content (use proper delimiter handling)
echo "Debug: CI_TEMPLATE_INFO first 50 chars: ${CI_TEMPLATE_INFO:0:50}..."
TARGET_FILE=$(echo "$CI_TEMPLATE_INFO" | head -n1)
TEMPLATE_CONTENT=$(echo "$CI_TEMPLATE_INFO" | tail -n +2)

echo "Debug: TARGET_FILE after extraction: $TARGET_FILE"
echo "Debug: TEMPLATE_CONTENT first 50 chars: ${TEMPLATE_CONTENT:0:50}..."

# Fork the repository
echo "Forking repository..."
FORK_RESPONSE=$(curl -s -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$ORIGINAL_OWNER/$ORIGINAL_REPO/forks)

# Check if fork was successful
if [[ $(echo "$FORK_RESPONSE" | jq -r '.id // empty') == "empty" || $(echo "$FORK_RESPONSE" | jq -r '.id') == "null" ]]; then
  echo "Error: Failed to fork repository" >&2
  echo "$FORK_RESPONSE" >&2
  exit 1
fi

# Extract forked repo details
FORKED_OWNER=$(echo $FORK_RESPONSE | jq -r '.owner.login')
FORKED_REPO=$(echo $FORK_RESPONSE | jq -r '.name')

echo "Repository successfully forked to $FORKED_OWNER/$FORKED_REPO"

# Export forked repo details for setup scripts
export FORKED_OWNER
export FORKED_REPO
export SITE_TYPE
export TARGET_BRANCH

# Base64 encode the CI config content
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS version (doesn't support -w)
  ENCODED_CONTENT=$(echo "$TEMPLATE_CONTENT" | base64 | tr -d '\n')
else
  # Linux version
  ENCODED_CONTENT=$(echo "$TEMPLATE_CONTENT" | base64 -w 0)
fi

# Wait for fork to be ready (GitHub API may need some time to complete the fork)
echo "Waiting for fork to be fully created..."
sleep 15

# Print debug info
echo "Debug: TARGET_FILE=$TARGET_FILE"
echo "Debug: Checking for directory structure..."

# Handle directory creation if needed
if [[ "$TARGET_FILE" == *"/"* ]]; then
  # Extract directory path from target file
  echo "Debug: Extracting directory path from $TARGET_FILE"
  DIR_PATH=$(dirname "$TARGET_FILE" 2>/dev/null || echo "")
  
  if [ -z "$DIR_PATH" ]; then
    echo "Error: Failed to extract directory path from $TARGET_FILE" >&2
    exit 1
  fi
  
  # Create directory structure if needed
  echo "Creating directory structure for CI configuration: $DIR_PATH"
  
  # Check if directory exists
  echo "Debug: Checking if $DIR_PATH exists in the repository"
  DIR_CHECK_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/contents/$DIR_PATH)
  
  echo "Debug: Directory check response: $DIR_CHECK_RESPONSE"
  
  # If directory doesn't exist (404), create it with a .gitkeep file
  if [ "$DIR_CHECK_RESPONSE" -eq 404 ]; then
    echo "Directory $DIR_PATH doesn't exist, creating it..."
    
    # Create each directory level as needed
    IFS='/' read -ra DIR_PARTS <<< "$DIR_PATH"
    CURRENT_PATH=""
    
    for DIR_PART in "${DIR_PARTS[@]}"; do
      if [ -n "$CURRENT_PATH" ]; then
        CURRENT_PATH="$CURRENT_PATH/$DIR_PART"
      else
        CURRENT_PATH="$DIR_PART"
      fi
      
      # Check if this level exists
      LEVEL_CHECK=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/contents/$CURRENT_PATH)
      
      if [ "$LEVEL_CHECK" -eq 404 ]; then
        # Create .gitkeep file to create the directory
        echo "Creating directory: $CURRENT_PATH"
        
        # Base64 encode empty content (compatible with macOS and Linux)
        if [[ "$OSTYPE" == "darwin"* ]]; then
          # macOS version (doesn't support -w)
          ENCODED_EMPTY=$(echo '' | base64)
        else
          # Linux version
          ENCODED_EMPTY=$(echo '' | base64 -w 0)
        fi
        
        curl -s -X PUT \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $GITHUB_TOKEN" \
          -H "X-GitHub-Api-Version: 2022-11-28" \
          https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/contents/$CURRENT_PATH/.gitkeep \
          -d "{
            \"message\": \"Create $CURRENT_PATH directory\",
            \"content\": \"$ENCODED_EMPTY\",
            \"branch\": \"$TARGET_BRANCH\"
          }" > /dev/null
      fi
    done
  fi
fi

# Create the CI configuration file
echo "Adding $CI_TYPE CI configuration to $TARGET_FILE..."
echo "Debug: TEMPLATE_CONTENT length: $(echo "$TEMPLATE_CONTENT" | wc -c) characters"
echo "Debug: ENCODED_CONTENT length: $(echo "$ENCODED_CONTENT" | wc -c) characters"

# Check if file already exists and get SHA if it does
FILE_INFO_RESPONSE=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/contents/$TARGET_FILE)

EXISTING_SHA=$(echo "$FILE_INFO_RESPONSE" | jq -r '.sha // empty')
echo "Debug: Existing file SHA: $EXISTING_SHA"

# Prepare request data with or without SHA
if [ -n "$EXISTING_SHA" ]; then
  REQUEST_DATA="{
    \"message\": \"Update $CI_TYPE CI configuration for $SITE_TYPE site with $HOSTING_TYPE hosting\",
    \"content\": \"$ENCODED_CONTENT\",
    \"sha\": \"$EXISTING_SHA\",
    \"branch\": \"$TARGET_BRANCH\"
  }"
  echo "Debug: Updating existing file"
else
  REQUEST_DATA="{
    \"message\": \"Add $CI_TYPE CI configuration for $SITE_TYPE site with $HOSTING_TYPE hosting\",
    \"content\": \"$ENCODED_CONTENT\",
    \"branch\": \"$TARGET_BRANCH\"
  }"
  echo "Debug: Creating new file"
fi

# Create or update the CI configuration file
WORKFLOW_RESPONSE=$(curl -s -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/contents/$TARGET_FILE \
  -d "$REQUEST_DATA")

# Debug: Extract key information from response using jq for reliability
CONTENT_PATH=$(echo "$WORKFLOW_RESPONSE" | jq -r '.content.path // empty')
COMMIT_SHA=$(echo "$WORKFLOW_RESPONSE" | jq -r '.commit.sha // empty')

echo "Debug: Content path: $CONTENT_PATH"
echo "Debug: Commit SHA: $COMMIT_SHA"

# Check if CI configuration file creation was successful
if [ -z "$CONTENT_PATH" ] || [ -z "$COMMIT_SHA" ]; then
  if [[ "$CONTENT_PATH" == "null" || "$COMMIT_SHA" == "null" ]]; then
      echo "Error: Failed to create $CI_TYPE configuration file (null values received)." >&2
  else
      echo "Error: Failed to create $CI_TYPE configuration file (empty values received)." >&2
  fi
  echo "Full API Response:" >&2
  echo "$WORKFLOW_RESPONSE" >&2
  exit 1
fi

echo "Successfully added $CI_TYPE configuration to $CONTENT_PATH"

# Set up hosting provider
if [[ "$HOSTING_TYPE" == "vercel" ]]; then
  echo "Setting up Vercel for branch deployments..."
  bash hosting/vercel_setup.sh
elif [[ "$HOSTING_TYPE" == "netlify" ]]; then
  echo "Setting up Netlify for branch deployments..."
  bash hosting/netlify_setup.sh
fi

echo "$CI_TYPE CI pipeline has been successfully added to the forked repository!"
echo "Fork URL: https://github.com/$FORKED_OWNER/$FORKED_REPO"
echo "CI Config URL: https://github.com/$FORKED_OWNER/$FORKED_REPO/blob/$TARGET_BRANCH/$TARGET_FILE"

# Create development branch if requested
if [ "$CREATE_DEV_BRANCH" = "true" ]; then
  echo "Creating development branch..."
  # Get SHA of the target branch head
  TARGET_BRANCH_SHA=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/git/refs/heads/$TARGET_BRANCH | jq -r '.object.sha // empty')

  if [ -z "$TARGET_BRANCH_SHA" ] || [ "$TARGET_BRANCH_SHA" == "null" ]; then
    echo "Error: Could not get SHA for branch $TARGET_BRANCH to create development branch." >&2
  else
    CREATE_BRANCH_RESPONSE=$(curl -s -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/$FORKED_OWNER/$FORKED_REPO/git/refs \
      -d "{
        \"ref\": \"refs/heads/development\",
        \"sha\": \"$TARGET_BRANCH_SHA\"
      }")
    
    # Check if branch creation was successful (jq '.ref' will exist on success)
    if echo "$CREATE_BRANCH_RESPONSE" | jq -e '.ref' > /dev/null; then
      echo "Development branch created. It will be automatically deployed."
      if [[ "$HOSTING_TYPE" == "netlify" ]]; then
        echo "Development site will be available at: https://development--$FORKED_REPO.netlify.app"
      elif [[ "$HOSTING_TYPE" == "vercel" ]]; then
        echo "Development site will be available at: https://$FORKED_REPO-git-development-$FORKED_OWNER.vercel.app"
      fi
    else
      echo "Error: Failed to create development branch." >&2
      echo "$CREATE_BRANCH_RESPONSE" >&2
    fi
  fi
fi 