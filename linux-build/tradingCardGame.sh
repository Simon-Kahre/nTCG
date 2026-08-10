#!/bin/sh
printf '\033c\033]0;%s\a' tradingCardGame
base_path="$(dirname "$(realpath "$0")")"
"$base_path/tradingCardGame.x86_64" "$@"
