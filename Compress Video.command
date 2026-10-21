#!/bin/bash
# macOS: double-click to pick videos. First time only, in Terminal: chmod +x "Compress Video.command"
cd "$(dirname "$0")" && bash ./compress-video.sh "$@"
read -n 1 -s -r -p "Press any key to close..."
