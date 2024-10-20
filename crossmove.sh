#!/bin/bash

# Directory containing the converted media files
moved_dir="/mnt/media/moved"

# Path to the CSV file
csv_file="transcode_log.csv"

# Iterate over each file in the moved directory
for file in "$moved_dir"/*.mp4; do
    # Extract the basename without the -AV1 suffix and file extension
    base_name=$(basename "$file" | sed 's/-AV1//' | sed 's/\.[^.]*$//')

    # Debug: Print the base name

    echo "Processing file: $file"
    if [[ debug == "true" ]]; then
        echo "Base name: '$base_name'"
    fi

    # Use grep to find the line containing the base name
    csv_line=$(grep -F "$base_name" "$csv_file")

    if [[ debug == "true" ]]; then
        # Debug: Print the CSV line found
        echo "CSV line: '$csv_line'"
    fi

    # Extract the destination path from the CSV line
    dest_path=$(echo "$csv_line" | awk -F, '{print $4}')

    if [[ debug == "true" ]]; then
        # Debug: Print the destination path
        echo "Destination path: '$dest_path'"
    fi
    # Check if a destination path was found
    if [ -n "$dest_path" ]; then
        # Construct the full destination file path
        dest_file="$dest_path/$(basename "$file")"

        # Check if the file already exists in the destination directory
        if [ -e "$dest_file" ]; then
            echo -e "\e[31mFile EXISTS in dest dir.\e[0m"
        else
            echo -e "\e[32mFile DOES NOT exist in destination.\e[0m"
        fi

        # Move the file to the destination path, overwriting if necessary
        mv -f "$file" "$dest_path"
        echo "Moved file to $dest_path "
        echo -e "\e[32mOK\e[0m"
        echo ""
    else
        echo "No match found for $file"
        echo -e "\e[31mUNSUCCESSFUL\e[0m"
    fi
done
