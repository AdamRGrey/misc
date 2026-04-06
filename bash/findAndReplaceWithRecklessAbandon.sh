#!/bin/bash

sed -i "s/$1/$2/g" `rg -l "$1"`
