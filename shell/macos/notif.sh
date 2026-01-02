# macOS notification wrapper
# Usage: notif <command>
# Shows a notification when the command completes

notif() {
  local cmd="$*"

  # Run the command passed to the function
  "$@"

  # Check the exit status of the command
  if [ $? -eq 0 ]; then
    osascript -e "display notification \"Task completed successfully: $cmd\" with title \"Notification\""
  else
    osascript -e "display notification \"Task failed: $cmd\" with title \"Notification\""
  fi
}
