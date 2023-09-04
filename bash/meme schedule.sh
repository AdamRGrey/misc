#!/bin/bash

for f in ./*
do
	filename=$(basename -- "$f")
	extension="${filename##*.}"
	filename="${filename%.*}"

	if [ "$filename" == "$(date '+%Y-%m-%d')" ]; then
		#echo $f
		curl -H "Content-Type: multipart/form-data" -F "file=@$f" #webhook url
	fi
done