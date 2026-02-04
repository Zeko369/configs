# Safe rm - uses trash instead of permanent deletion

# Keep reference to real rm
local real_rm=$(which rm)
alias _rm="$real_rm"
alias realrm="$real_rm"

# Detect trash command (macOS: trash, Linux: trash-put)
if command -v trash &> /dev/null; then
  _trash_cmd="trash"
elif command -v trash-put &> /dev/null; then
  _trash_cmd="trash-put"
else
  _trash_cmd=""
fi

# Safe rm function that uses trash instead of permanent deletion
function rm() {
  # Check if trash command exists
  if [[ -z "$_trash_cmd" ]]; then
    echo "Warning: trash command not found. Install 'trash' (macOS) or 'trash-cli' (Linux), or use 'realrm' for permanent deletion."
    return 1
  fi

  # Check if -f flag is present (force, ignore non-existent files)
  local force_flag=false
  local files=()

  for arg in "$@"; do
    # Check if this is a flag (starting with -)
    if [[ "$arg" =~ ^- ]]; then
      # Check if -f is in the flags (could be -f, -rf, -fr, -Rf, etc.)
      if [[ "$arg" =~ f ]]; then
        force_flag=true
      fi
      # Skip all flags (we're just using them to determine behavior)
    else
      # This is a file/directory argument
      files+=("$arg")
    fi
  done

  # If no files were provided after filtering, show usage
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files or directories specified"
    return 1
  fi

  # If -f flag is present, filter out non-existent files
  if [[ "$force_flag" == true ]]; then
    local existing_files=()
    for file in "${files[@]}"; do
      if [[ -e "$file" ]]; then
        existing_files+=("$file")
      fi
    done
    files=("${existing_files[@]}")

    # If no files exist after filtering, silently succeed (like rm -f does)
    if [[ ${#files[@]} -eq 0 ]]; then
      return 0
    fi
  fi

  # Use trash for the filtered file arguments
  $_trash_cmd "${files[@]}"
}
