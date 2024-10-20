#!/bin/bash

# Check if a filename argument is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a filename as an argument."
    exit 1
fi

# Get the filename from the argument
filename="$1"

# Search for the file in the current directory
if [ -f "$filename" ]; then
    echo "File found: $filename"

    # Check if the file has more than one hard link
    link_count=$(stat -c %h "$filename")
    if [ "$link_count" -gt 1 ]; then
        echo "File has multiple hard links. Removing this hard link."
        rm "$filename"
    else
        echo "File has only one hard link. Keeping the file intact."
    fi

    # Create a new hard link in the specified directory
    base_name=$(basename "$filename")
    mp4_name="${base_name%.*}.mp4"
    target_file="/mnt/user/UnsortedMovies/after/$mp4_name"

    if [ -f "$target_file" ]; then
        ln "$target_file" "$mp4_name"
        echo "Created hard link: $mp4_name"
    else
        echo "Error: Target file not found: $target_file"
        exit 1
    fi
else
    echo "Error: File not found in the current directory: $filename"
    exit 1
fi