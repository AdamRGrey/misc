#/bin/bash
#thanks, bewilderex63. https://unix.stackexchange.com/questions/51840/how-to-disable-trash-can-in-thunar-xfce

# Once at the start for good measure
rm -rf .local/share/Trash/files/*

while [ true ]
do
    inotifywait ~/.local/share/Trash/files

    # Don't get stuck in a CPU-melting loop if something goes wrong
    if [ $? -ne 0 ]
    then
        exit $?
    fi

    # Good riddance
    rm -rf .local/share/Trash/files/*
done
