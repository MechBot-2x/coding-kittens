#!/bin/bash
# github_repo_setup.sh - Secure GitHub repository creation script

# Configuration
ORG_NAME="MechBot-2x"
REPO_NAME="coding-kittens"
DEFAULT_BRANCH="main"
REPO_DESCRIPTION="Quantum programming with cats 🐱💻"
REPO_VISIBILITY="false"  # false = public, true = private

# Function to securely prompt for token
get_github_token() {
  if [ -z "$GITHUB_TOKEN" ]; then
    echo -n "Enter GitHub Personal Access Token: "
    read -s GITHUB_TOKEN
    echo
  fi
}

# Function to verify token
verify_token() {
  echo "Verifying GitHub token..."
  response=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user)

  if [ "$response" -ne 200 ]; then
    echo "❌ Invalid token (HTTP $response)"
    return 1
  fi
  echo "✅ Token verified"
  return 0
}

# Function to create repository
create_repository() {
  echo "Creating repository $REPO_NAME under $ORG_NAME..."
  response=$(curl -s -o response.json -w "%{http_code}" \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/$ORG_NAME/repos \
    -d '{
      "name": "'$REPO_NAME'",
      "description": "'"$REPO_DESCRIPTION"'",
      "private": '$REPO_VISIBILITY',
      "auto_init": false,
      "default_branch": "'$DEFAULT_BRANCH'"
    }')

  if [ "$response" -eq 201 ]; then
    echo "✅ Repository created successfully"
    REPO_URL=$(jq -r '.html_url' response.json)
    echo "🔗 $REPO_URL"
    rm response.json
    return 0
  else
    echo "❌ Failed to create repository (HTTP $response)"
    jq . response.json
    rm response.json
    return 1
  fi
}

# Function to set up git remote
setup_git_remote() {
  if [ -d .git ]; then
    echo "Configuring git remote..."
    git remote add origin https://$GITHUB_TOKEN@github.com/$ORG_NAME/$REPO_NAME.git
    git branch -M $DEFAULT_BRANCH
    git push -u origin $DEFAULT_BRANCH
    echo "✅ Git remote configured"
  else
    echo "⚠️ Not a git repository. Run 'git init' first."
  fi
}

# Main execution
get_github_token
if verify_token; then
  if create_repository; then
    setup_git_remote
  fi
fi

# Security recommendation
unset GITHUB_TOKEN
echo "🚀 Repository setup complete!"
