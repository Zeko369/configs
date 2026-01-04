# Git worktree helpers
# gwc: Create a new worktree in worktrees-<repo>/<branch-name>
# Usage: gwc <branch-name> [--no-cd] [--master]
function gwc() {
  local branch_name=""
  local no_cd=false
  local from_master=false

  # Parse arguments
  for arg in "$@"; do
    if [[ "$arg" == "--no-cd" ]]; then
      no_cd=true
    elif [[ "$arg" == "--master" ]]; then
      from_master=true
    elif [[ -z "$branch_name" ]]; then
      branch_name="$arg"
    fi
  done

  # Check if branch name provided
  if [[ -z "$branch_name" ]]; then
    echo "Usage: gwc <branch-name> [--no-cd] [--master]"
    echo "  Creates a new git worktree in worktrees-<repo>/<branch-name>"
    echo "  --no-cd: Don't change to the new worktree directory"
    echo "  --master: Create branch from master instead of current branch"
    return 1
  fi

  # Get the git root directory
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$git_root" ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  local repo_name=$(basename "$git_root")
  local worktree_base=""

  # Check if we're already inside a worktrees-<repo> directory
  local current_dir=$(pwd)
  local parent_dir=$(dirname "$current_dir")
  local grandparent_dir=$(dirname "$parent_dir")

  if [[ "$(basename "$parent_dir")" == worktrees-* ]]; then
    # We're in worktrees-<repo>/<some-branch>, use parent as base
    worktree_base="$parent_dir"
  elif [[ "$(basename "$grandparent_dir")" == worktrees-* ]]; then
    # We're deeper in a worktree, use grandparent
    worktree_base="$grandparent_dir"
  else
    # We're in the main repo, create worktrees-<repo> next to it
    worktree_base="$(dirname "$git_root")/worktrees-$repo_name"
  fi

  local worktree_path="$worktree_base/$branch_name"

  # Create worktree base directory if it doesn't exist
  if [[ ! -d "$worktree_base" ]]; then
    echo "Creating worktree directory: $worktree_base"
    mkdir -p "$worktree_base"
  fi

  # Check if worktree already exists
  if [[ -d "$worktree_path" ]]; then
    echo "Error: Worktree already exists at $worktree_path"
    return 1
  fi

  # Check if branch already exists
  local branch_exists=false
  if git rev-parse --verify "$branch_name" &>/dev/null; then
    branch_exists=true
    echo "Branch $branch_name already exists, checking it out..."
  fi

  # Determine base branch
  local base_branch=""
  if [[ "$from_master" == true ]]; then
    base_branch="master"
  fi

  # Create the worktree
  if [[ "$branch_exists" == true ]]; then
    # Branch exists, just checkout
    echo "Creating worktree at $worktree_path with existing branch $branch_name..."
    git worktree add "$worktree_path" "$branch_name"
  elif [[ -n "$base_branch" ]]; then
    # Create new branch from specified base
    echo "Creating worktree at $worktree_path with new branch $branch_name from $base_branch..."
    git worktree add -b "$branch_name" "$worktree_path" "$base_branch"
  else
    # Create new branch from current branch
    echo "Creating worktree at $worktree_path with new branch $branch_name..."
    git worktree add -b "$branch_name" "$worktree_path"
  fi

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create worktree"
    return 1
  fi

  # Run mise trust in the new worktree
  echo "Running mise trust..."
  (cd "$worktree_path" && mise trust 2>/dev/null)

  # CD into the new worktree unless --no-cd was passed
  if [[ "$no_cd" == false ]]; then
    echo "Changing to $worktree_path"
    cd "$worktree_path"
  else
    echo "Worktree created at: $worktree_path"
  fi
}

# gwd: Delete the current worktree (must be run from within a worktree)
# Usage: gwd [-f|--force]
function gwd() {
  local force=false
  if [[ "$1" == "-f" || "$1" == "--force" ]]; then
    force=true
  fi

  local current_dir=$(pwd)
  local dir_name=$(basename "$current_dir")
  local parent_dir=$(dirname "$current_dir")
  local parent_name=$(basename "$parent_dir")

  # Check if we're in a worktrees-<repo>/<branch> structure
  if [[ "$parent_name" != worktrees-* ]]; then
    echo "Error: Not in a worktree directory"
    echo "Expected to be in worktrees-<repo>/<branch-name>"
    return 1
  fi

  # Verify this is actually a git worktree
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "Error: Not in a git repository"
    return 1
  fi

  local branch_name=$(git rev-parse --abbrev-ref HEAD)

  # Confirm deletion
  if [[ "$force" == false ]]; then
    echo "This will remove:"
    echo "  - Worktree: $current_dir"
    echo "  - Branch: $branch_name"
    echo ""
    read -q "REPLY?Are you sure? (y/N) "
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 0
    fi
  fi

  # Move to parent directory first
  cd "$parent_dir"

  # Remove the worktree
  echo "Removing worktree..."
  git worktree remove "$current_dir" --force

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to remove worktree"
    return 1
  fi

  # Delete the branch
  echo "Deleting branch $branch_name..."
  git branch -D "$branch_name" 2>/dev/null

  echo "Done! Worktree and branch removed."
}
