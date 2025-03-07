#!/usr/bin/env bash

# Interactive menu with arrow key navigation
# Usage: ./menu.sh "Select option" opt1 opt2 opt3 opt4

set -u

declare OPTIONS=()
declare PROMPT="Select an option:"
declare SELECTED=0

# Clear the screen
clear_screen() {
  printf "\033c"
}

# Hide cursor
hide_cursor() {
  printf "\e[?25l"
}

# Show cursor
show_cursor() {
  printf "\e[?25h"
}

# Function to display the menu
display_menu() {
  clear_screen
  printf "%s\n" "$PROMPT"

  for i in "${!OPTIONS[@]}"; do
    if [ "$i" -eq "$SELECTED" ]; then
      printf "[×] %s\n" "${OPTIONS[$i]}"
    else
      printf "[ ] %s\n" "${OPTIONS[$i]}"
    fi
  done
}

# Capture key presses
key_press() {
  local key
  IFS= read -rsn1 key 2>/dev/null >&2
  if [[ $key = $'\e' ]]; then
    read -rsn2 key
    case $key in
    '[A') echo "up" ;;   # Up arrow
    '[B') echo "down" ;; # Down arrow
    *) echo "other" ;;
    esac
  elif [[ $key = "" ]]; then
    echo "enter"
  else
    echo "other"
  fi
}

# Main function
main() {
  PROMPT=$1
  readonly PROMPT
  shift
  OPTIONS=("$@")
  readonly OPTIONS
  local total=${#OPTIONS[@]}

  hide_cursor
  trap show_cursor EXIT # Ensure cursor is shown when script exits

  # Display menu initially
  display_menu

  # Main loop
  while true; do
    # Get key press
    key=$(key_press)

    case $key in
    up)
      # Move selection up
      ((SELECTED--))
      if ((SELECTED < 0)); then
        SELECTED=$((total - 1))
      fi
      display_menu options "$PROMPT" $SELECTED
      ;;
    down)
      # Move selection down
      ((SELECTED++))
      if [ $SELECTED -ge "$total" ]; then
        SELECTED=0
      fi
      display_menu
      ;;
    enter)
      # User pressed Enter, return the selected option
      clear_screen
      show_cursor
      echo "You selected: ${OPTIONS[$SELECTED]}"
      exit 0
      ;;
    *)
      # Ignore other keys
      ;;
    esac
  done
}

main "$@"
