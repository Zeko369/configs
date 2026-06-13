#!/bin/zsh

_configs_trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s\n' "$value"
}

_configs_expand_repo_path() {
  local repo="$1"
  repo="${repo/#\~/$HOME}"
  repo="${repo/#\$HOME/$HOME}"
  printf '%s\n' "$repo"
}

_configs_path_in_no_git_repo() {
  local path="${1:-$PWD}"
  local line repo
  local repos_file="${CONFIGS_NO_GIT_REPOS_FILE:-$CONFIGS_DIR/shell/no-git-repos}"

  [[ -r "$repos_file" ]] || return 1

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    repo="$(_configs_trim "$line")"
    [[ -n "$repo" ]] || continue

    repo="$(_configs_expand_repo_path "$repo")"
    if [[ "$path" == "$repo" || "$path" == "$repo"/* ]]; then
      return 0
    fi
  done < "$repos_file"

  return 1
}
