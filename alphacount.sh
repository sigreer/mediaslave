#!/bin/bash

# Function to count directories by their first character and AV1 mp4 files
count_directories_and_av1() {
    local dir="$1"
    shift
    local show_duplicates=false
    local show_converted=false

    # Parse additional arguments
    for arg in "$@"; do
        case "$arg" in
            --show-duplicates)
                show_duplicates=true
                ;;
            --show-converted)
                show_converted=true
                ;;
        esac
    done

    # Ensure the provided argument is a directory
    if [ ! -d "$dir" ]; then
        echo "Error: $dir is not a directory."
        exit 1
    fi

    # Initialize associative arrays to hold counts
    declare -A dir_count
    declare -A av1_count

    local total_dirs=0
    local total_av1_dirs=0

    # Array to store directories with duplicate AV1 files
    local duplicate_dirs=()

    # Array to store directories with non-AV1 video files with the same basename
    local non_av1_duplicate_dirs=()

    # Iterate over directories in the specified directory
    for subdir in "$dir"/*/; do
        # Use carriage return to overwrite the previous line
        echo -ne "Processing directory: $subdir\r"
        ((total_dirs++))
        # Get the first character of the directory name and convert it to lowercase
        first_char=$(basename "$subdir" | cut -c1 | tr '[:upper:]' '[:lower:]')

        # Determine if the first character is alphanumeric
        if [[ "$first_char" =~ [a-zA-Z0-9] ]]; then
            # Increment the count for this character
            ((dir_count["$first_char"]++))
        else
            # Increment the count for non-alphanumeric group
            ((dir_count["non-alphanumeric"]++))
        fi

        # Check if the directory contains AV1 mp4 files
        # av1_files_count=$(find "$subdir" -maxdepth 1 -type f -name "*AV1.mp4" | wc -l)
        av1_files_count=$(ls "$subdir"/*AV1.mp4 2>/dev/null | wc -l)
        if (( av1_files_count > 0 )); then
            ((av1_count["$first_char"]++))
            ((total_av1_dirs++))
        fi

        # If --show-duplicates is provided, store directories with more than one AV1.mp4 file
        if [[ "$show_duplicates" == "--show-duplicates" && av1_files_count -gt 1 ]]; then
            duplicate_dirs+=("$subdir")
        fi
    done
    
    echo ""

    # Sort the keys, ensuring "non-alphanumeric" is at the end
    sorted_keys=($(printf "%s\n" "${!dir_count[@]}" | grep -v "non-alphanumeric" | sort))
    if [[ -n "${dir_count["non-alphanumeric"]}" ]]; then
        sorted_keys+=("non-alphanumeric")
    fi

    # Calculate the number of rows needed
    num_keys=${#sorted_keys[@]}
    num_columns=4
    num_rows=$(( (num_keys + num_columns - 1) / num_columns ))

    # Print the results in columns
    for ((i=0; i<num_rows; i++)); do
        for ((j=i; j<num_keys; j+=num_rows)); do
            key="${sorted_keys[j]}"
            av1_count_display=${av1_count["$key"]:0}
            printf "%-20s" "${key}: ${av1_count_display}/${dir_count[$key]}"
        done
        echo
    done

    # Print the summary of total directories containing AV1 files
    echo ""
    if (( total_dirs > 0 )); then
        local percentage=$(( 100 * total_av1_dirs / total_dirs ))
        echo "Directories containing AV1 mp4 files: $total_av1_dirs/$total_dirs ($percentage%)"
    else
        echo "No sub-directories found."
    fi

    # Output the duplicates after the summaries
    if $show_duplicates && [[ ${#duplicate_dirs[@]} -gt 0 ]]; then
        echo ""
        echo "Directories with duplicate AV1.mp4 files:"
        for dir in "${duplicate_dirs[@]}"; do
            echo "$dir"
        done
    fi

    # Output directories with non-AV1 video files with the same basename
    if $show_converted && [[ ${#non_av1_duplicate_dirs[@]} -gt 0 ]]; then
        echo ""
        echo "Directories with non-AV1 video files having the same basename:"
        for dir in "${non_av1_duplicate_dirs[@]}"; do
            echo "$dir"
        done
    fi
}

# Check if a directory is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory> [--show-duplicates] [--show-converted]"
    exit 1
fi

# Call the function with the provided directory and optional flags
count_directories_and_av1 "$@"