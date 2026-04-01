#!/bin/bash
yt-dlp  \
    --cookies-from-browser "firefox:~/.librewolf/ugbom7sa.default-default/" \
    --output "/home/adam/.local/bin/convertqueue/%(playlist)s/%(playlist_index)s - %(title)s - [%(id)s].%(ext)s" \
    --format "bv+ba/best" \
    --js-runtimes bun \
    --no-sponsorblock \
    "$1"
