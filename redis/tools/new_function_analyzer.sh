#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <old_binary> <new_binary>"
    exit 1
fi

old_binary=$1
new_binary=$2

nm -g $old_binary | grep ' T ' | awk '{print $3}' | sort > old_functions.txt
nm -g $new_binary | grep ' T ' | awk '{print $3}' | sort > new_functions.txt

comm -13 old_functions.txt new_functions.txt > new_function.txt

rm old_functions.txt new_functions.txt