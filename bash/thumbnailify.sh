#!/bin/bash

if [ ! -f "$@" ]; then
	echo "file to thumbnailify plz"
fi

fullfilename=$(basename -- "$@")
extension="${fullfilename##*.}"
filename="${fullfilename%.*}"

pushd $(dirname "$@")

if [ -f "$filename""_thumbless.$extension" ]; then
	echo "there's already a _thumbless in here... I think i'm already done?"
	exit 1
fi

if [ -f "testframe.mp4" ] || [ -f "thumbnailism.txt" ]; then
	echo "my temp files are already here... I think i'm redundant?"
	exit 1
fi

echo "file testframe.mp4" > thumbnailism.txt
echo "file $fullfilename" >> thumbnailism.txt

ffmpeg -i "$fullfilename" -ss 1.5 -to 1.51666 testframe.mp4
ffmpeg -f concat -i thumbnailism.txt -c copy output.mp4

mv "$fullfilename" "$filename""_thumbless.$extension"
mv output.mp4 "$fullfilename"
rm thumbnailism.txt
rm testframe.mp4

popd
