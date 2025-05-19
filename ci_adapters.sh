#!/bin/bash

# Load CI templates based on CI_TYPE
get_ci_template() {
  local ci_type=$1
  local destination_path=$2
  local target_branch=$3
  local site_type=${4:-"generic"}
  local hosting_type=${5:-"vercel"}
  local target_file=""
  local template_file=""
  
  echo "Debug: CI Type=$ci_type, Site Type=$site_type, Hosting Type=$hosting_type" >&2
  
  case $ci_type in
    github|github-actions|github_actions)
      if [[ "$site_type" == "jekyll" && "$hosting_type" == "netlify" ]]; then
        template_file="ci_adapters/github_actions_jekyll_netlify.yml"
      elif [[ "$site_type" == "jekyll" && "$hosting_type" == "vercel" ]]; then
        template_file="ci_adapters/github_actions_jekyll.yml"
      elif [[ "$site_type" == "jekyll" ]]; then
        # Default to Vercel for Jekyll if no specific hosting is set
        template_file="ci_adapters/github_actions_jekyll.yml"
      elif [[ "$hosting_type" == "netlify" ]]; then
        template_file="ci_adapters/github_actions_netlify.yml"
      elif [[ "$hosting_type" == "vercel" ]]; then
        # Use a vercel-specific template if available, otherwise use standard template
        if [ -f "ci_adapters/github_actions_vercel.yml" ]; then
          template_file="ci_adapters/github_actions_vercel.yml"
        else
          template_file="ci_adapters/github_actions.yml"
        fi
      else
        template_file="ci_adapters/github_actions.yml"
      fi
      target_file=".github/workflows/ci.yml"
      ;;
    gitlab|gitlab-ci|gitlab_ci)
      template_file="ci_adapters/gitlab_ci.yml"
      target_file=".gitlab-ci.yml"
      ;;
    circle|circleci|circle_ci)
      template_file="ci_adapters/circle_ci.yml"
      target_file=".circleci/config.yml"
      ;;
    travis|travis-ci|travis_ci)
      template_file="ci_adapters/travis_ci.yml"
      target_file=".travis.yml"
      ;;
    jenkins|jenkins-pipeline)
      template_file="ci_adapters/jenkins_pipeline"
      target_file="Jenkinsfile"
      ;;
    azure|azure-pipelines|azure_pipelines)
      template_file="ci_adapters/azure_pipelines.yml"
      target_file="azure-pipelines.yml"
      ;;
    bitbucket|bitbucket-pipelines|bitbucket_pipelines)
      template_file="ci_adapters/bitbucket_pipelines.yml"
      target_file="bitbucket-pipelines.yml"
      ;;
    *)
      echo "Error: Unsupported CI type: $ci_type" >&2
      echo "Supported types: github-actions, gitlab-ci, circle-ci, travis-ci, jenkins, azure-pipelines, bitbucket-pipelines" >&2
      return 1
      ;;
  esac
  
  # Load template content
  if [ ! -f "$template_file" ]; then
    echo "Error: Template file not found: $template_file" >&2
    return 1
  fi
  
  # Replace placeholder variables in template if needed
  local template_content=$(cat "$template_file")
  
  # Return target file on first line and template content on subsequent lines
  echo "$target_file"
  echo "$template_content"
}

# List all available CI adapters
list_ci_adapters() {
  echo "Available CI Adapters:"
  echo "  github-actions   - GitHub Actions workflow"
  echo "  gitlab-ci        - GitLab CI pipeline"
  echo "  circle-ci        - CircleCI config"
  echo "  travis-ci        - Travis CI config"
  echo "  jenkins          - Jenkins pipeline"
  echo "  azure-pipelines  - Azure DevOps Pipelines"
  echo "  bitbucket-pipelines - Bitbucket Pipelines"
  echo ""
  echo "Site Type Options:"
  echo "  generic          - Generic website (auto-detected)"
  echo "  jekyll           - Jekyll static site (auto-detected)"
  echo ""
  echo "Hosting Options:"
  echo "  vercel           - Vercel hosting with branch deployments (default)"
  echo "  netlify          - Netlify hosting with branch deployments"
}

# If script is executed directly, show available adapters
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  list_ci_adapters
fi 