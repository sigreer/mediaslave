#!/bin/bash

# Define variables
VIDEO_DIR="$1"
ERROR_LOG="/tank/NextcloudSideSys/Dev/vermeer/quickcheck.log"

# Create or clear the error log
> "$ERROR_LOG"

# Function to check file integrity
check_integrity() {
    local file="$1"
    echo "Checking integrity of: $file"
    echo "Checking integrity of: $file" >> "$ERROR_LOG"
    if ffmpeg -v error -i "$file" -f null - 2>> "$ERROR_LOG"; then
        echo -e "\e[32mPASS\e[0m: $file"
        echo "PASS: $file" >> "$ERROR_LOG"
    else
        echo -e "\e[31mFAIL\e[0m: $file"
        echo "FAIL: $file" >> "$ERROR_LOG"
    fi
}

# Check if VIDEO_DIR is provided and exists
if [ -z "$VIDEO_DIR" ] || [ ! -d "$VIDEO_DIR" ]; then
    echo "Error: Invalid or no directory specified. Usage: $0 <video_directory>" >&2
    exit 1
fi

echo "Starting quick integrity check in directory: $VIDEO_DIR"
echo "Starting quick integrity check in directory: $VIDEO_DIR at $(date)" >> "$ERROR_LOG"

# Find and check video files
while IFS= read -r -d '' file; do
    # Remove leading './' from the file path if present
    file="${file#./}"
    # Ensure the file path starts with the VIDEO_DIR
    if [[ "$file" != "$VIDEO_DIR"* ]]; then
        file="$VIDEO_DIR/$file"
    fi
    check_integrity "$file"
done < <(find "$VIDEO_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) -print0)

# Check if any files were found
if [ -z "$(find "$VIDEO_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \))" ]; then
    echo "No video files found in $VIDEO_DIR"
    echo "No video files found in $VIDEO_DIR" >> "$ERROR_LOG"
fi

echo "Quick integrity check complete. Review $ERROR_LOG for full results."
echo "Quick integrity check completed at $(date)" >> "$ERROR_LOG"
