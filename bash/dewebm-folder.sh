#!/bin/bash

for f in *.webm
do
    fullfilename=$(basename -- "$f")
    extension="${fullfilename##*.}"
    filename="${fullfilename%.*}"
    ffmpeg -i "$f" "$filename.mp4"
    echo "$f -> $filename"
    sleep 3
    rm "$f"
done
