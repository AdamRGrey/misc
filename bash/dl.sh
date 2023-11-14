#!/bin/bash

starttime=$(date)
yt-dlp --output "%(upload_date)s - %(title)s - [%(id)s].%(ext)s" \
    --format "bv*[ext=mp4]+ba/best" \
    --sponsorblock-remove all \
    -a "$@" \
    --download-archive "done.txt"

for file in *.webm
do
    #surely there's a smarter way to just download mp4? or just prefer not webm?
    ffmpeg -i "$file" "$file.mp4"    
    #rm "$file"
done
for file in *.mkv
do
    ffmpeg -i "$file" "$file.mp4"    
    #rm "$file"
done

if [ $(wc -l < "$@") -eq $(wc -l < done.txt) ]
then
    echo "looks like all downloads worked. :)"
    rm "$@"
    rm done.txt
fi

echo "started $starttime"
echo "completed $(date)"
echo "(idk how to datemath)"