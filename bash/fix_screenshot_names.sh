#!/bin/bash

# vlc MUST have a screenshot prefix. -_-

cd ~/Pictures/0/screenshots
while :
do
    sleep 600
    for i in ./*
    do
        if [[ "$i" == ./Screenshot_* ]]
        then 
            mv "$i" "$(echo $i | sed 's/Screenshot_//')"
        fi
        
        if [[ "$i" == ./vlcsnap-* ]]
        then
            mv "$i" "$(echo $i | sed 's/vlcsnap-//')"
        fi
    done
done
