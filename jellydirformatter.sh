#!/bin/bash

scan() {
  # Specify the directory to search through
  BASE_DIR="$1"

  # Check if the directory is provided and exists
  if [ -z "$BASE_DIR" ]; then
    echo "Please provide a base directory."
    exit 1
  fi

  if [ ! -d "$BASE_DIR" ]; then
    echo "The specified directory does not exist."
    exit 1
  fi

  # Create or overwrite the CSV file
  CSV_FILE="directory_report.csv"
  echo "Name,Type,Contains Media,Media Format,Conforms to Naming,Size (MB),Size (GB)" > "$CSV_FILE"

  # Function to check if a directory contains media files and return the format
  contains_media() {
    local formats=("avi" "mp4" "mkv" "wmv" "mov")
    for format in "${formats[@]}"; do
      if find "$1" -maxdepth 1 -type f -iname "*.$format" | grep -q .; then
        echo "$format"
        return 0
      fi
    done
    echo "none"
    return 1
  }

  # Function to display progress bar
  show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    printf "\rProgress: [%s%s] %d%%" "$(printf '#%.0s' $(seq 1 $completed))" "$(printf ' %.0s' $(seq 1 $remaining))" "$percentage"
  }

  # Function to properly escape CSV fields
  escape_csv() {
    local field="$1"
    if [[ $field == *[,\"$'\n']* ]]; then
      field="${field//\"/\"\"}"
      echo "\"$field\""
    else
      echo "$field"
    fi
  }

  # Function to check if bc is available
  bc_available() {
    command -v bc >/dev/null 2>&1
  }

  # Function to perform division without bc
  divide() {
    echo $(( ($1 * 100) / $2 )) | sed 's/..$/.&/'
  }

  # Function to check if a directory name conforms to the naming convention
  conforms_to_naming() {
    local name="$1"
    if [[ $name =~ \([0-9]{4}\)$ ]]; then
      echo "yes"
    else
      echo "no"
    fi
  }

  # Count total items
  TOTAL_ITEMS=$(find "$BASE_DIR" -maxdepth 1 | wc -l)
  TOTAL_ITEMS=$((TOTAL_ITEMS - 1))  # Subtract 1 to account for the directory itself
  echo "Total items in directory: $TOTAL_ITEMS"

  # Initialize counters and arrays for summary
  TOTAL_DIRS=0
  TOTAL_FILES=0
  DIRS_NO_MEDIA=0
  DIRS_INCORRECT_NAME=0
  declare -A MEDIA_TYPE_COUNT
  declare -A MEDIA_TYPE_SIZE
  declare -A MEDIA_TYPE_MAX_SIZE
  TOTAL_DIR_SIZE=0

  # Initialize counter
  COUNTER=0

  # Loop through all items in the base directory
  for ITEM in "$BASE_DIR"/*; do
    NAME=$(basename "$ITEM")
    
    if [ -d "$ITEM" ]; then
      TYPE="dir"
      TOTAL_DIRS=$((TOTAL_DIRS + 1))
      MEDIA_FORMAT=$(contains_media "$ITEM")
      if [ "$MEDIA_FORMAT" != "none" ]; then
        CONTAINS_MEDIA="yes"
        MEDIA_TYPE_COUNT[$MEDIA_FORMAT]=$((MEDIA_TYPE_COUNT[$MEDIA_FORMAT] + 1))
        SIZE_MB=$(du -sm "$ITEM" | cut -f1)
        MEDIA_TYPE_SIZE[$MEDIA_FORMAT]=$((MEDIA_TYPE_SIZE[$MEDIA_FORMAT] + SIZE_MB))
        if [ -z "${MEDIA_TYPE_MAX_SIZE[$MEDIA_FORMAT]}" ] || [ $SIZE_MB -gt ${MEDIA_TYPE_MAX_SIZE[$MEDIA_FORMAT]} ]; then
          MEDIA_TYPE_MAX_SIZE[$MEDIA_FORMAT]=$SIZE_MB
        fi
      else
        CONTAINS_MEDIA="no"
        DIRS_NO_MEDIA=$((DIRS_NO_MEDIA + 1))
      fi
      CONFORMS_NAMING=$(conforms_to_naming "$NAME")
      if [ "$CONFORMS_NAMING" = "no" ]; then
        DIRS_INCORRECT_NAME=$((DIRS_INCORRECT_NAME + 1))
      fi
      if bc_available; then
        SIZE_GB=$(echo "scale=2; $SIZE_MB / 1024" | bc)
      else
        SIZE_GB=$(divide $(($SIZE_MB * 100)) 102400)
      fi
      TOTAL_DIR_SIZE=$((TOTAL_DIR_SIZE + SIZE_MB))
    else
      TYPE="file"
      TOTAL_FILES=$((TOTAL_FILES + 1))
      CONTAINS_MEDIA="n/a"
      MEDIA_FORMAT="n/a"
      CONFORMS_NAMING="n/a"
      SIZE_MB=$(du -sm "$ITEM" | cut -f1)
      if bc_available; then
        SIZE_GB=$(echo "scale=2; $SIZE_MB / 1024" | bc)
      else
        SIZE_GB=$(divide $(($SIZE_MB * 100)) 102400)
      fi
    fi

    # Escape fields for CSV
    ESCAPED_NAME=$(escape_csv "$NAME")
    ESCAPED_TYPE=$(escape_csv "$TYPE")
    ESCAPED_CONTAINS_MEDIA=$(escape_csv "$CONTAINS_MEDIA")
    ESCAPED_MEDIA_FORMAT=$(escape_csv "$MEDIA_FORMAT")
    ESCAPED_CONFORMS_NAMING=$(escape_csv "$CONFORMS_NAMING")
    ESCAPED_SIZE_MB=$(escape_csv "$SIZE_MB")
    ESCAPED_SIZE_GB=$(escape_csv "$SIZE_GB")
    
    # Append to CSV
    echo "$ESCAPED_NAME,$ESCAPED_TYPE,$ESCAPED_CONTAINS_MEDIA,$ESCAPED_MEDIA_FORMAT,$ESCAPED_CONFORMS_NAMING,$ESCAPED_SIZE_MB,$ESCAPED_SIZE_GB" >> "$CSV_FILE"

    # Update progress
    COUNTER=$((COUNTER + 1))
    show_progress $COUNTER $TOTAL_ITEMS
  done

  echo -e "\nReport generated: $CSV_FILE"

  # Print summary
  echo -e "\nSummary:"
  echo "TOTAL DIRS:             $TOTAL_DIRS"
  echo "TOTAL FILES:            $TOTAL_FILES"
  echo "DIRS WITH NO MEDIA:     $DIRS_NO_MEDIA"
  echo "DIRS INCORRECTLY NAMED: $DIRS_INCORRECT_NAME"

  echo -e "\nMedia Type Statistics:"
  for format in "${!MEDIA_TYPE_COUNT[@]}"; do
    count=${MEDIA_TYPE_COUNT[$format]}
    total_size=${MEDIA_TYPE_SIZE[$format]}
    if bc_available; then
      avg_size=$(echo "scale=2; $total_size / $count" | bc)
    else
      avg_size=$(divide $total_size $count)
    fi
    max_size=${MEDIA_TYPE_MAX_SIZE[$format]}
    echo "$format:"
    echo "  Count:           $count"
    echo "  Avg Size (MB):   $avg_size"
    echo "  Max Size (MB):   $max_size"
  done

  if bc_available; then
    avg_dir_size=$(echo "scale=2; $TOTAL_DIR_SIZE / $TOTAL_DIRS" | bc)
  else
    avg_dir_size=$(divide $TOTAL_DIR_SIZE $TOTAL_DIRS)
  fi
  echo -e "\nOverall Directory Statistics:"
  echo "Average Dir Size (MB): $avg_dir_size"


}

cleanup() {
  BASE_DIR="$1"

  # Check if the directory is provided and exists
  if [ -z "$BASE_DIR" ]; then
    echo "Please provide a base directory."
    exit 1
  fi

  if [ ! -d "$BASE_DIR" ]; then
    echo "The specified directory does not exist."
    exit 1
  fi

  CSV_FILE="directory_report.csv"

  # Check if the CSV file exists
  if [ ! -f "$CSV_FILE" ]; then
    echo "CSV file not found. Please run the scan function first."
    exit 1
  fi

  echo "Analyzing directories without media files..."

  # Count directories to be removed
  dirs_to_remove=0
  while IFS=',' read -r name type contains_media _; do
    if [ "$type" = "dir" ] && [ "$contains_media" = "no" ]; then
      dirs_to_remove=$((dirs_to_remove + 1))
    fi
  done < <(tail -n +2 "$CSV_FILE")

  # Display warning and wait for confirmation
  echo "WARNING: This will delete $dirs_to_remove directories that contain no media."
  read -p "Press Enter to continue or Ctrl+C to cancel..."

  echo "Removing directories without media files..."

  # Read the CSV file and remove directories without media
  tail -n +2 "$CSV_FILE" | while IFS=',' read -r name type contains_media _; do
    if [ "$type" = "dir" ] && [ "$contains_media" = "no" ]; then
      dir_path="$BASE_DIR/$name"
      if [ -d "$dir_path" ]; then
        echo "Removing: $dir_path"
        rm -rf "$dir_path"
      fi
    fi
  done

  echo "Cleanup completed. Removed $dirs_to_remove directories."
}

dasherrorcheck() {
  echo "" > output.txt && find . -mindepth 1 -maxdepth 1 -type d | grep -E '.*\w-\s.*' | while read -r dir; do
    if [ -z "$(find "$dir" -mindepth 1 -print -quit)" ]; then
        echo "EMPTY: $dir" >> output.txt
    else
        echo "NOTEMPTY: $dir" >> output.txt
    fi
done
echo EMPTY DIRS...
cat output.txt | grep EMPTY
echo NOTEMPTY DIRS...
cat output.txt | grep NOT
}

# Main script logic
if [ $# -lt 2 ]; then
  echo "Usage: $0 <command> <path>"
  echo "Commands: scan, cleanup"
  exit 1
fi

command="$1"
path="$2"

case "$command" in
  scan)
    scan "$path"
    ;;
  cleanup)
    cleanup "$path"
    ;;
  dasherror)
    dasherrorcheck "$path"
  *)
    echo "Invalid command. Use 'scan', 'cleanup' or 'dasherror'."
    exit 1
    ;;
esac

