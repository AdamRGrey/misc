#!/bin/bash

mkdir temp  && cd "$_"
#wget -r -l 1 -A jpg,jpeg,png,gif,bmp -nd -H <your link here>

for f in *.*
do
	if [[ "$f" == *s.* ]]; then
		rm $f
	elif [[ "$f" =~ \.tmp(\.[\d]+)? ]]; then
		rm $f
	fi
done