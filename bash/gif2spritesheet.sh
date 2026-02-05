#!/bin/bash

INPUT=$1
OUTPUT=$2
FRAMES=$(ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -of csv=p=0 $INPUT)

# Extract video duration in seconds
DURATION_S=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $INPUT)

# Calculate the FPS if we want to show 20 frames in our sprite sheet
FPS=$(echo "scale=8; $FRAMES / $DURATION_S" | bc)

# Generate the sprite sheet
ffmpeg \
  -y \
  -i "$INPUT" \
  -frames 1 \
  -q:v 2 \
  -filter_complex "tile=1x$FRAMES" \
  $OUTPUT
