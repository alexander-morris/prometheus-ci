#!/bin/bash
set -e # Exit on error

# --- Configuration ---
TEST_REPO_URL="" # To be set by the user or as an argument
# Example: TEST_REPO_URL="https://github.com/actions/starter-workflows"
# Example: TEST_REPO_URL="https://github.com/jekyll/jekyll-now"

# --- Helper Functions ---
log_info() { echo "[INFO] $1"; }
log_error() { echo "[ERROR] $1" >&2; }
log_success() { echo "[SUCCESS] $1"; }
log_warn() { echo "[WARN] $1"; }

# --- Pre-flight checks ---
check_dependencies() {
    log_info "Checking dependencies..."
    command -v jq >/dev/null 2>&1 || { log_error "jq is not installed. Please install it."; exit 1; }
    command -v curl >/dev/null 2>&1 || { log_error "curl is not installed. Please install it."; exit 1; }
    command -v git >/dev/null 2>&1 || { log_error "git is not installed. Please install it."; exit 1; }
    
    if [ ! -f "fork_and_add_ci.sh" ]; then
        log_error "Main script fork_and_add_ci.sh not found in the current directory."; exit 1;
    fi
    
    # Ensure all utility scripts are executable
    log_info "Setting execute permissions for scripts..."
    chmod +x fork_and_add_ci.sh repo_parser.sh ci_adapters.sh
    if [ -d "hosting" ]; then
        chmod +x hosting/*.sh
    fi
    log_success "Dependencies and permissions checked."
}

# --- Environment Setup ---
setup_env() {
    log_info "Setting up test environment..."
    if [ ! -f ".env" ]; then
        log_error ".env file not found. Please create it from env.sample and configure it with your tokens."
        log_info "Required in .env: GITHUB_TOKEN, and VERCEL_TOKEN (for Vercel) or NETLIFY_AUTH_TOKEN (for Netlify)."
        exit 1
    fi

    # Check for essential tokens in .env
    local github_token_present=$(grep -c "^GITHUB_TOKEN=your_github_personal_access_token" .env)
    local vercel_token_present=$(grep -c "^VERCEL_TOKEN=your_vercel_auth_token" .env)
    local netlify_token_present=$(grep -c "^NETLIFY_AUTH_TOKEN=your_netlify_auth_token" .env)
    
    local vercel_configured=0
    if grep -q "^VERCEL_TOKEN=" .env && [ "$vercel_token_present" -eq 0 ]; then
        vercel_configured=1
    fi

    local netlify_configured=0
    if grep -q "^NETLIFY_AUTH_TOKEN=" .env && [ "$netlify_token_present" -eq 0 ]; then
        netlify_configured=1
    fi

    local hosting_token_configured=$(( vercel_configured || netlify_configured ))

    local github_is_ok=0
    # Correctly check the command status for github_token_configured
    if grep -q "^GITHUB_TOKEN=" .env && [ "$github_token_present" -eq 0 ]; then
      github_is_ok=1
    fi

    if [ "$github_is_ok" -eq 0 ] || [ "$hosting_token_configured" -eq 0 ]; then
        log_error "Essential tokens (GITHUB_TOKEN and VERCEL_TOKEN/NETLIFY_AUTH_TOKEN) not found or appear to be using placeholder values in .env."
        log_error "Please ensure they are correctly set to your actual tokens."
        exit 1
    fi
    
    # Backup original .env
    cp .env .env.bak_test
    log_info "Original .env file backed up to .env.bak_test"

    # Create a temporary .env for the test
    # Remove existing ORIGINAL_REPO_URL and CREATE_DEV_BRANCH, then add the test ones
    grep -v "^ORIGINAL_REPO_URL=" .env.bak_test | grep -v "^CREATE_DEV_BRANCH=" > .env
    echo "ORIGINAL_REPO_URL=$TEST_REPO_URL" >> .env
    echo "CREATE_DEV_BRANCH=true" >> .env # Ensure dev branch creation is tested
    log_info "Temporary .env configured with TEST_REPO_URL: $TEST_REPO_URL and CREATE_DEV_BRANCH=true"
}

# --- Test Execution ---
run_test() {
    log_info "Starting full flow test with repository: $TEST_REPO_URL"
    
    # Run the main script and capture output to test_output.log and also print to stdout/stderr
    if ./fork_and_add_ci.sh 2>&1 | tee test_output.log; then
        # Check exit status from pipe
        # shellcheck disable=SC2181 # $? is valid here
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            log_success "fork_and_add_ci.sh executed successfully."
        else
            log_error "fork_and_add_ci.sh failed with exit code ${PIPESTATUS[0]}. Check test_output.log and above output for details."
            return 1
        fi
    else
        # This block might not be reached if set -e is active and tee fails,
        # but kept for robustness with potential changes.
        log_error "fork_and_add_ci.sh execution failed. Check test_output.log."
        return 1
    fi
    return 0
}

# --- Verification ---
verify_output() {
    log_info "Verifying output from test_output.log..."
    local success=true
    
    # Check for key success messages
    grep -q "Repository successfully forked to" test_output.log || { log_warn "Fork success message not found."; success=false; }
    grep -q "Successfully added .* CI configuration to" test_output.log || { log_warn "CI configuration success message not found."; success=false; }
    
    # Check for hosting setup success
    if grep -q "Setting up Vercel" test_output.log; then
        grep -q "Vercel setup complete!" test_output.log || { log_warn "Vercel setup complete message not found."; success=false; }
    elif grep -q "Setting up Netlify" test_output.log; then
        grep -q "Netlify setup complete!" test_output.log || { log_warn "Netlify setup complete message not found."; success=false; }
    else
        # This might indicate an issue if a hosting provider was expected
        if grep -q "VERCEL_TOKEN=" .env || grep -q "NETLIFY_AUTH_TOKEN=" .env; then
            log_warn "Neither Vercel nor Netlify setup messages found, but tokens seem to be configured."
        fi
    fi

    grep -q "CI pipeline has been successfully added" test_output.log || { log_warn "Overall success message not found."; success=false; }
    grep -q "Fork URL:" test_output.log || { log_warn "Fork URL message not found."; success=false; }
    grep -q "CI Config URL:" test_output.log || { log_warn "CI Config URL message not found."; success=false; }

    # Since the test script sets CREATE_DEV_BRANCH=true
    grep -q "Development branch created." test_output.log || { log_warn "Development branch creation message not found."; success=false; }
    grep -q "Development site will be available at:" test_output.log || { log_warn "Development site URL message not found."; success=false; }
    

    if $success; then
        log_success "Output verification passed. Key messages found."
        echo "----------------------------------------------------------------------"
        log_success "Summary of created resources (from script output):"
        grep "Fork URL:" test_output.log
        grep "CI Config URL:" test_output.log
        grep -E "(Vercel project created:|Netlify site created:)" -A 3 test_output.log || true
        grep "production site will be available at:" test_output.log || true
        grep "Vercel setup complete!" -A 2 test_output.log | grep -Ev "(Vercel setup complete!)" || true
        grep "Netlify setup complete!" -A 2 test_output.log | grep -Ev "(Netlify setup complete!)" || true
        grep "Development site will be available at:" test_output.log || true
        echo "----------------------------------------------------------------------"

    else
        log_error "Output verification failed. Some key messages were not found. Please review test_output.log and the script output above."
    fi
    return $(if $success; then echo 0; else echo 1; fi)
}

# --- Cleanup ---
cleanup_env() {
    log_info "Cleaning up test environment..."
    if [ -f ".env.bak_test" ]; then
        mv .env.bak_test .env
        log_info "Original .env file restored."
    else
        log_warn ".env.bak_test not found, couldn't restore original .env. This is unexpected if setup_env ran."
    fi
    # rm -f test_output.log # Keep log for inspection after script finishes
    log_info "Kept test_output.log for review."
}

# --- Main ---
main() {
    # Prompt for TEST_REPO_URL if not set
    if [ -z "$TEST_REPO_URL" ]; then
        read -p "Enter the GitHub repository URL to use for testing (e.g., https://github.com/jekyll/jekyll-now): " TEST_REPO_URL_INPUT
        if [ -z "$TEST_REPO_URL_INPUT" ]; then
            log_error "Test repository URL cannot be empty."
            exit 1
        fi
        TEST_REPO_URL="$TEST_REPO_URL_INPUT"
    fi

    trap cleanup_env EXIT # Ensure cleanup happens on script exit (normal or error)

    check_dependencies
    setup_env # This will exit if .env is not properly configured
    
    final_status=1
    if run_test; then
        if verify_output; then
            log_success "Full flow test completed successfully for $TEST_REPO_URL."
            final_status=0
        else
            log_error "Full flow test completed with verification failures for $TEST_REPO_URL."
        fi
    else
        log_error "Full flow test failed during execution for $TEST_REPO_URL."
    fi
    
    if [ $final_status -eq 0 ]; then
        log_warn "MANUAL CLEANUP REQUIRED: Please delete the forked repository on GitHub (e.g., $(grep 'Fork URL:' test_output.log | awk '{print $3}') ) and any projects created on Vercel/Netlify."
    else
        log_error "Test failed. Review messages above and in test_output.log."
    fi
    exit $final_status
}

# --- Argument parsing for TEST_REPO_URL ---
if [ "$1" ]; then
    TEST_REPO_URL="$1"
fi

main 