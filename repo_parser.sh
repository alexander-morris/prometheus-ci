#!/bin/bash

# Function to parse GitHub repository URL and extract owner and repo name
parse_github_url() {
  local repo_url=$1
  local owner=""
  local repo=""
  
  # Handle different GitHub URL formats
  if [[ $repo_url =~ ^https://github.com/([^/]+)/([^/\.]+)(\.git)?$ ]]; then
    # Format: https://github.com/owner/repo or https://github.com/owner/repo.git
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  elif [[ $repo_url =~ ^git@github.com:([^/]+)/([^/\.]+)(\.git)?$ ]]; then
    # Format: git@github.com:owner/repo.git
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  elif [[ $repo_url =~ ^([^/]+)/([^/\.]+)$ ]]; then
    # Format: owner/repo
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  else
    echo "Error: Invalid GitHub repository URL format: $repo_url" >&2
    echo "Valid formats: https://github.com/owner/repo, git@github.com:owner/repo.git, owner/repo" >&2
    return 1
  fi
  
  # Check if owner and repo were successfully extracted
  if [ -z "$owner" ] || [ -z "$repo" ]; then
    echo "Error: Failed to extract owner and repository name from URL: $repo_url" >&2
    return 1
  fi
  
  # Return the extracted owner and repo name
  echo "$owner|$repo"
}

# Function to detect repository type and settings
detect_repo_type() {
  local owner=$1
  local repo=$2
  local site_type="generic"
  
  # Use GitHub API to get repository details
  local repo_info=$(curl -s -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$owner/$repo")
  
  # Check for Jekyll indicators
  if curl -s -I -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://raw.githubusercontent.com/$owner/$repo/main/_config.yml" | grep -q "200 OK"; then
    site_type="jekyll"
  elif curl -s -I -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://raw.githubusercontent.com/$owner/$repo/master/_config.yml" | grep -q "200 OK"; then
    site_type="jekyll"
  elif echo "$repo_info" | grep -q '"language":"Ruby"'; then
    # Additional check for Ruby language, which might indicate Jekyll
    site_type="jekyll"
  fi
  
  # Detect default branch
  local default_branch=$(echo "$repo_info" | jq -r '.default_branch')
  if [ -z "$default_branch" ] || [ "$default_branch" == "null" ]; then
    default_branch="main"
  fi
  
  # Return detected settings
  echo "$site_type|$default_branch"
}

# If script is executed directly, process the command line argument
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ $# -lt 1 ]; then
    echo "Usage: $0 <github_repo_url>" >&2
    exit 1
  fi
  
  parse_github_url "$1"
fi 