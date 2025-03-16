#!/usr/bin/env bash

set -u

# Function to display a progress bar
# Usage: progress-bar <progress>
udpate_bar() {
    local percent_done="$1"
    local columns
    local space_available
    local progress
    local space_length
    local i

    columns=80
    space_available=$((columns - 7))
    progress=$((percent_done * space_available / 100))
    space_length=$((space_available - progress))

    printf "\r["
    if ((progress > 0)); then
        printf "%0.s#" $(seq $progress)
    fi
    printf "%0.s " $(seq $space_length)
    printf "] %d%%" "$percent_done"
}

udpate_bar "$@"
