#!/bin/bash

#
# phase 1: take screenshots
#

if [ ! -d "screenshots" ]; then
  mkdir screenshots
fi

find . -iname "*.mp4" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	#extension="${filename##*.}"
	filename="${filename%.*}"
	ffmpeg -ss 0 -i $file -vf fps=0.5 ./screenshots/$filename%d.png
done

#
# phase 2: img preprocess
#

if [ ! -d "preproccessed" ]; then
  mkdir preproccessed
fi
find "screenshots" -iname "*.png" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	convert "$file" -gravity SouthWest -crop 560x60+0+0  -fuzz 12% +transparent "#edf1c9" "preproccessed/$filename.png"
done

#
# phase 3: ocr
#

if [ ! -d "ocr" ]; then
  mkdir ocr
fi
find "preproccessed" -iname "*.png" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	tesseract $file "ocr/$filename"
done

#
# phase 4: prep for geotagging
#


if [ ! -d "tagged" ]; then
  mkdir tagged
fi
find "screenshots" -iname "*.png" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	convert $file "tagged/$filename.jpg"
	exiftool -overwrite_original -TagsFromFile ./knowngood.jpg -All:All "tagged/$filename.jpg"
done