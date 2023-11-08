#!/bin/bash

echo "#"
echo "# phase 1: take screenshots"
echo "#"

if [ ! -d "screenshots" ]; then
  mkdir screenshots
fi

find . -iname "*.mp4" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	#extension="${filename##*.}"
	filename="${filename%.*}"
	ffmpeg -ss 0 -i $file -vf fps=0.5 ./screenshots/$filename-%d.png
done

echo "#"
echo "# phase 2: img preprocess"
echo "#"

if [ ! -d "preproccessed" ]; then
  mkdir preproccessed
fi
find "screenshots" -iname "*.png" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	convert "$file" -gravity SouthWest -crop 560x48+0+8  -fuzz 12% +transparent "#edf1c9" "preproccessed/$filename.png"
done

echo "#"
echo "# phase 3: ocr"
echo "#"

if [ ! -d "ocr" ]; then
  mkdir ocr
fi
find "preproccessed" -iname "*.png" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	tesseract $file "ocr/$filename" -c tessedit_char_whitelist=" 0123456789KM/HNW."	
	sed -i 's/ //g' "ocr/$filename.txt"

done

echo "#"
echo "# phase 4: prep for geotagging"
echo "#"
if [ ! -d "tagged" ]; then
  mkdir tagged
fi
find "screenshots" -iname "*.png" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	convert $file "tagged/$filename.jpg"
done
exiftool -overwrite_original -TagsFromFile ./knowngood.jpg -All:All "tagged/*.jpg"

echo "#"
echo "# phase 5: if ocr was good, geotag. Otherwise, reject."
echo "#"
goodreads=0
badreads=0
if [ ! -d "badread" ]; then
  mkdir badread
fi
find "ocr" -iname "*.txt" -print0 | while read -d $'\0' file
do
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	
	n=$(grep -Poh "(?<=N)[0-9]{2}\\.[0-9]+" "$file")
	w=$(grep -Poh "(?<=W)[0-9]{2}\\.[0-9]+" "$file")

	if [ -n "$n" ] && [ -n "$w" ]; then
		goodreads=$(($goodreads+1))
		echo "$filename was OCR'd well; $goodreads good so far"
		exiftool -overwrite_original -gpslatitude="$n" -gpslongitude="-$w" -GPSLatitudeRef="North" -GPSLongitudeRef="West" "tagged/$filename.jpg"
	else
		badreads=$(($badreads+1))
		echo "$filename is not perfect; $badreads bad so far"
		mv "tagged/$filename.jpg" "badread/$filename.jpg"
		mv "ocr/$filename.txt" "badread/$filename.txt"
		mv "preproccessed/$filename.png" "badread/$filename.png"
	fi
done

echo "$goodreads good, $badreads bad. accuracy:"
bc <<< "scale=4; goodreads=$goodreads; badreads=$badreads; ratio=100*goodreads/(goodreads+badreads);ratio"
