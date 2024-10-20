#!/bin/bash
input_path=$1

declare video_bitdepth
declare pix_fmt
declare audio_bitrate
export SVT_LOG=1

dev_mode=0
# Convert the input path to an absolute path
input_path=$(realpath "$input_path")

# Set the fallback defaults
master_file=/mnt/media/master_file_list
input_files_list="/mnt/media/input_files_list.txt"
transcode_csv_file="/mnt/media/transcode_log.csv"
valid_extensions=("mp4" "mov" "m4a" "mkv" "avi" "flv" "wmv" "mpg" "mpeg" "webm" "ts")
verbosity=2
declare log_file_writable=false

# Function to log messages based on verbosity level
logthis() {
    local level=$1
    shift
    local message="$@"
    
    # Get the current timestamp
    local timestamp=$(date '+%y-%m-%d %H:%M')
    local short_timestamp=$(date '+%H:%M')
    # Map the numeric level to a descriptive string
    local level_str
    case $level in
        1) level_str="DEBUG" ;;
        2) level_str="INFO" ;;
        3) level_str="IMPORTANT" ;;
        4) level_str="CRITICAL" ;;
        *) level_str="UNKNOWN" ;;
    esac
    
    # Construct the log message
    local log_console_message="$message"
    local log_file_message="$timestamp $node_name $level_str: $message"
    if [[ $level -ge $verbosity ]]; then
        echo "$log_console_message"
        if [[ $log_to_file == "true" && $log_file_writable == "true" ]]; then
          echo "$log_file_message" >> "$log_file"
        fi
    fi
}


check_log_file_permissions() {
    local log_dir
    log_dir=$(dirname "$log_file")

    # Check if the log file exists
    if [[ ! -f "$log_file" ]]; then
        logthis 2 "Log file does not exist. Checking directory permissions to create it."
        # Check if the directory is writable
        if [[ -w "$log_dir" ]]; then
            touch "$log_file" && logthis 1 "Log file created: $log_file" || logthis 4 "Failed to create log file: $log_file"
        else
            logthis 3 "Directory $log_dir is not writable. Cannot create log file."
        fi
    fi

    # Check if the log file is writable
    if [[ -w "$log_file" ]]; then
        log_file_writable=true
    else
        logthis 3 "Log file $log_file is not writable."
    fi
}

config() {
  : "${log_to_file:=false}"
  : "${log_file:=/var/log/av1encode.log}"
  env_file="$HOME/.env-av1encode"
  if [[ -f $env_file ]]; then
    source "$env_file"
    echo "Using ${env_file}"
    if [[ -n "${TRANSCODE_DIR}" ]]; then
        transcoding_directory="${TRANSCODE_DIR}"
    fi
    if [[ -n "${TRANSCODE_FAIL_ACTION}" ]]; then
        transcode_fail_action=$TRANSCODE_FAIL_ACTION
    fi
    if [[ -n "${RSYNC_RECEIVE_FAIL_ACTION}" ]]; then
        rsync_receive_fail_action="${RSYNC_RECEIVE_FAIL_ACTION}"
    fi
    if [[ -n "${RSYNC_SEND_FAIL_ACTION}" ]]; then
        rsync_send_fail_action="${RSYNC_SEND_FAIL_ACTION}"
    fi
    if [[ -n "${RSYNC_SEND_FAIL_LIST}" ]]; then
        rsync_send_fail_list="${RSYNC_SEND_FAIL_LIST}"
    fi
    if [[ -n "${LOG_TO_FILE}" ]]; then
        log_to_file="${LOG_TO_FILE}"
    fi
    if [[ -n "${LOG_FILE}" ]]; then
        log_file="${LOG_FILE}"
    fi
    if [[ -n "${VERBOSITY}" ]]; then
        verbosity="${VERBOSITY}"
    fi
    if [[ -n "${NODE_NAME}" ]]; then
        node_name="${NODE_NAME}"
    fi
    if [[ -n "${LOCAL_FILE_EXISTS_ACTION}" ]]; then
        local_file_exists_action="${LOCAL_FILE_EXISTS_ACTION}"
    fi
  fi
  hostname=$(hostname)
  if [[ -z $node_name ]]; then
    node_name=$hostname
  fi
    echo "Node:                 ${node_name}"
    echo "Log to file:          ${log_to_file}"
    echo "Log file path:        ${log_file}"
    : "${transcode_fail_action:=exit}"
    echo "On transcode fail:    ${transcode_fail_action}"
    : "${rsync_send_fail_action:=keep_local_and_exit}"
    echo "On file send fail:    ${rsync_send_fail_action}"
    : "${rsync_receive_fail_action:=exit}"
    echo "On file receive fail: ${rsync_receive_fail_action}"
    : "${transcoding_directory:=$HOME/transcodes}"
    echo "Local transcode dir:  ${transcoding_directory}"
    : "${local_file_exists_action:=delete_local}"
    echo "If local file exists: ${local_file_exists_action}"
    echo ""
    echo "exit the script now if any of these values are incorrect"
}

# Function to expand ranges like A-G,1-4 into individual characters/numbers
expand_ranges() {
    local range_string="$1"
    local expanded=""
    IFS=',' read -ra ranges <<< "$range_string"
    for range in "${ranges[@]}"; do
        if [[ "$range" =~ ^[A-Za-z]-[A-Za-z]$ ]]; then
            expanded+=$(echo {${range:0:1}..${range:2:1}})
        elif [[ "$range" =~ ^[0-9]-[0-9]$ ]]; then
            expanded+=$(echo {${range:0:1}..${range:2:1}})
        else
            expanded+="$range"
        fi
    done
    echo "$expanded"
}



get_video_bitdepth() {
  # Get the pixel format from the video file using ffprobe
  pix_fmt=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=noprint_wrappers=1:nokey=1 "$1" | head -n 1)
    logthis 1 "FINISHED CHECKING pix_fmt. VALUE RETURNED WAS ${pix_fmt}"
    case "$pix_fmt" in
      yuv420p | yuv422p | yuv444p | nv12 | nv21)
        video_bitdepth=8
        ;;
      yuv420p10le | yuv422p10le | yuv444p10le | p010le)
        video_bitdepth=10
        ;;
      yuv420p12le | yuv422p12le | yuv444p12le)
        video_bitdepth=12
        ;;
      yuv420p16le | yuv422p16le | yuv444p16le)
        video_bitdepth=16
        ;;
      *)
        logthis 1 "Unknown bit depth for pixel format: $pix_fmt"
        video_bitdepth=unknown
        ;;
    esac
}

### THIS FUNCTION IS BEING DEVELOPED AND IS CURRENTLY NOT USED
get_audio_bitrate() {
  # Extract the audio stream to a temporary file
  output_audio="${transcoding_directory}/temp_audio.aac"
  ffmpeg-av1 -i "$1" -map 0:a:0 -c copy "$output_audio" -y
  logthis 1 "get_audio_bitrate FUNCTION RAN FFMPEG"
  # Get the audio file size in bytes
  file_size=$(stat --format="%s" "$output_audio")
  echo "AUDIO FILESIZE=${file_size}"

  # Extract the audio duration using ffmpeg (in seconds)
  duration=$(ffmpeg-av1 -i "$1" -map 0:a:0 -f null - 2>&1 | grep "time=" | tail -1 | awk -F'time=' '{print $2}' | awk '{print $1}')
  echo "AUDIO DURATION CALCULATION=${duration}"
    duration_seconds=$(echo "$duration" | awk -F':' '{ print ($1 * 3600) + ($2 * 60) + $3 }')
  echo "AUDIO DURATION IN SECONDS=${duration_seconds}"

  # Calculate the bitrate in kbps: (file_size in bits / duration in seconds) / 1000
  audio_bitrate=$(echo "scale=2; ($file_size * 8) / ($duration_seconds * 1000)" | bc)
  echo "FINAL BITRATE CALCULATION=${audio_bitrate}"

  # Clean up by removing the extracted audio file
  echo "DELETING EXTRACTED AUDIO FILE"
  rm -f "$output_audio"

  # Store the bitrate in a variable and output it
  echo "Bitrate: ${audio_bitrate}k"
}

transcode_file() {
    input_file=$1
    logthis 1 "$(date '+%Y-%m-%d %H:%M') PROCESSING $(basename "$input_file")"
    start_time=$(date +%s)
    filename=$(basename -- "$input_file")
    if [[ "$filename" == *-AV1.* ]]; then
        output_filename="$filename"
    else
        output_filename="${filename%.*}-AV1.mp4"
    fi
    input_directory=$(dirname -- "$input_file")
    logthis 2 "Receiving file ${input_file}"
    rsync -rtPh --progress --protect-args "$input_file" "$transcoding_directory/${filename}"
    local_input_file="$transcoding_directory/$filename"
    local_output_file="$transcoding_directory/${output_filename}"
    if ! get_video_bitdepth "$local_input_file"; then
        logthis 1 "RETURNED FROM get_video_bitdepth WITH 1"
        logthis 1 "SKIPPING: $local_input_file"
        logthis 1 "RETURNING FROM transcode_file WITH 1"
        rm -f "$local_input_file"  # Clean up the copied input file
        logthis 3 "Transcode failed: Unable to determine bitrate from source file"
        return 1
    fi
    # Check if the output file already exists and delete it if it does
    if [[ -f "$local_output_file" ]]; then
      logthis 2 "${filename} found in ${transcoding_directory}"
      case $local_file_exists_action in
        delete_local|overwrite)
          rm -f "$local_output_file" && logthis 2 "Deleted local file." || logthis 3 "Tried to delete local file but failed."
          ;;
        use_local)
          logthis 2 "Using existing local file: $local_output_file"
          return 0  # Skip transcoding and return success
          ;;
        *)
          logthis 3 "Unknown local_file_exists_action: $local_file_exists_action"
          ;;
      esac
      logthis 1 "Finished checking local output file"
    fi

    input_size_mb=$(bc <<< "scale=2; $(stat -c%s "$local_input_file") / 1048576")
    input_codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$local_input_file")
    if [[ $video_bitdepth == "unknown" ]]; then
      pix_fmt_arg=""
    else
      pix_fmt_arg="-pix_fmt ${pix_fmt}"
    fi
    if [[ "$local_input_file" == *.mp4 || "$input_file" == *.mov || "$input_file" == *.m4a ]]; then
        logthis 3 "Encoding with no progress bar..."
        ffmpeg-av1 -loglevel error -hide_banner -nostats -i "$input_file" \
        -c:v libsvtav1 -preset 8 -crf 35 -b:v 0 $pix_fmt_arg -c:a libopus -b:a 0 -strict experimental -movflags +faststart -f mp4 "$local_output_file"
    else
        logthis 3 "Encoding with progress bar..."
        pv "$local_input_file" | ffmpeg-av1 -loglevel error -hide_banner -nostats -i - -c:v libsvtav1 -preset 8 -crf 35 -b:v 0 $pix_fmt_arg -c:a libopus -b:a 0 -strict experimental -movflags +faststart -f mp4 "$local_output_file"
    fi
    
    ffmpeg_status=$?
    output_size_mb=$(bc <<< "scale=2; $(stat -c%s "$local_output_file") / 1048576")
    size_diff_mb=$(bc <<< "scale=2; $input_size_mb - $output_size_mb")
    size_diff_percent=$(bc <<< "scale=2; ($size_diff_mb / $input_size_mb) * 100")
    end_time=$(date +%s)
    time_taken=$((end_time - start_time))
    logthis 1 "Time taken for this file: ${time_taken} seconds"

    if [[ $ffmpeg_status -eq 0 ]]; then
        new_output_file="${input_directory}/$(basename "${local_output_file}")"
        rsync -rtPh --progress --protect-args "$local_output_file" "$new_output_file"
        file_return_status=$?
        if [[ $file_return_status -eq 0 ]]; then 
          transcode_date=$(date '+%Y-%m-%d %H:%M')
          echo "$transcode_date,$hostname,$input_file,$new_output_file,${filename##*.},$input_codec,$input_size_mb,$output_size_mb,$size_diff_mb,${size_diff_percent}%,$time_taken" >> "$transcode_csv_file" && logthis 1 "DONE"
          logthis 1 "WRITING OLD FILENAMES TO ${input_files_list}"
          add_to_input_files_list "$input_file" && logthis 1 "added to ${input_file} successfully"
          logthis 1 "DELETING ORIGINAL SOURCE FILE"
          source_cleanup "$input_file" && logthis 1 "Source cleanup finished successfully"
          local_cleanup && logthis 1 "Local cleanup finished successfully"
        else
          logthis 3 "rsync did not transfer the file to the original directory"
          if [[ $rsync_send_fail_action == "keep_local_and_continue" || $rsync_send_fail_action == "keep_local_and_exit" ]]; then
            echo "${local_output_file}" >> "$rsync_send_fail_list"
            logthis 3 "File kept. It's path has been stored in ${rsync_send_fail_list}"
            logthis 3 "To change this, add env RSYNC_SEND_FAIL_ACTION with a value of remove_local_and_continue or remove_local_and_exit"
          else
            rm "${local_output_file}"
            logthis 3 "File deleted."
            logthis 3 "To change this, add env RSYNC_SEND_FAIL_ACTION with a value of keep_local_and_continue or keep_local_and_exit"
          fi
          if [[ $rsync_send_fail_action == "exit" ]]; then
            logthis 4 "failed to move file after transcoding. EXITING SCRIPT"
            logthis 4 "to change this, add RSYNC_SEND_FAIL_ACTION=continue to your .env file"
            exit 1
          fi
        fi
    else
        logthis 4 "$(date '+%Y-%m-%d %H:%M:%S') TRANSCODE FAILED. FILE NOT MOVED."
        logthis 4 "Error details: $(ffmpeg-av1 -i "$local_input_file" 2>&1 | tail -n 1)"
        if [[ fail_transcode_action == "exit" ]]; then
          logthis 4 "fail_transcode_action set to exit. Failed to transcode. EXITING..."
          exit 1
        fi
    fi  
  }

source_cleanup() {
    local input_file="$1"
    logthis 1 "Deleting source file: ${input_file}"
    rm -f "$input_file" && logthis 1 "removed ${input_file}" || { logthis 3 "failed to remove ${input_file}"; return 1; }
}

local_cleanup() {
  rm -f "$local_input_file" && logthis 1 "removed ${local_input_file}" || { logthis 3 "failed to remove ${local_input_file}"; return 1; }
  rm -f "$local_output_file" && logthis 1 "removed ${local_output_file}" || { logthis 3 "failed to remove ${local_output_file}"; return 1; }
}



is_valid_media_file() {
  local file_extension="${1##*.}"
  for ext in "${valid_extensions[@]}"; do
    if [[ "$file_extension" == "$ext" ]]; then
      return 0
    fi
  done
  return 1
}

# Function to remove a file from the master list after conversion
remove_from_master_list() {
    local file_path="$1"
    sed -i "\|$file_path|d" "$master_file"
    logthis 1 "Removed from master list: $file_path"
}

# Function to add a file path to the input_files_list if it doesn't already exist
add_to_input_files_list() {
  if [[ ! -f "$input_files_list" ]]; then
    touch "$input_files_list"
    logthis 1 "Created input_files_list: $input_files_list"
  fi
    local file_path="$1"
    if ! grep -Fxq "$file_path" "$input_files_list"; then
        echo "$file_path" >> "$input_files_list"
        logthis 1 "Added to input_files_list: $file_path"
    else
        logthis 1 "File already exists in input_files_list: $file_path"
    fi
}

worker_cleanup() {
    logthis 1 "Cleaning up temporary files..."
    rm -f "$temp_file" && logthis 1 "Temporary file removed"
    logthis 1 "Cleanup complete."

}

# Function to handle the 'generate' command
generate_master_list() {
    local directory="$1"
    logthis 2 "Generating master list for directory: ${directory}"
    > "$master_file"  # Clear the master file before writing

    find "$directory" -type f ! -name "*-AV1.mp4" -not -path "*/.Trash-*" -print0 | while IFS= read -r -d '' file; do
        if is_valid_media_file "$file"; then
            printf '%s\n' "$file" >> "$master_file"
        fi
    done
    # Count and output the total number of files in the master list
    total_files=$(wc -l < "$master_file")

    logthis 2 "Master list generated at: $master_file"
    echo "Total unconverted files: $total_files"
}

# Function to handle the 'convert' command
convert_from_master_list() {
    local filtered_files=()

    if [[ -n "$starts_with" ]]; then
        expanded_starts_with=$(expand_ranges "$starts_with")
        while IFS= read -r file; do
            for prefix in $(echo "$expanded_starts_with" | sed "s/./& /g"); do
                if [[ $(basename "$file") == $prefix* ]]; then
                    filtered_files+=("$file")
                    break
                fi
            done
        done < "$master_file"
    else
        mapfile -t filtered_files < "$master_file"
    fi

    total_files=${#filtered_files[@]}
    current_file=0
    start_time=$(date +%s)
    estimated_time_per_file=900  # Initial estimate of 15 minutes per file
        # Calculate and log estimated completion time
    estimated_remaining_time=$((estimated_time_per_file * total_files))

    estimated_days=$((estimated_remaining_time / 86400))
    estimated_hours=$(( (estimated_remaining_time % 86400) / 3600 ))
    estimated_minutes=$(( (estimated_remaining_time % 3600) / 60 ))
    estimated_seconds=$((estimated_remaining_time % 60))
    estimated_completion_time=$(date -d "+${estimated_remaining_time} seconds" '+%Y-%m-%d %H:%M:%S')
    
    echo ""
    echo "Estimated Time:              ${estimated_days}d ${estimated_hours}h ${estimated_minutes}m ${estimated_seconds}s"
    echo "Estimated Finish:            ${estimated_completion_time}"

    for file in "${filtered_files[@]}"; do
        current_file=$((current_file + 1))
        logthis 2 "Processing file ${current_file}/${total_files}"
        transcode_file "$file"
        transcode_status=$?
        logthis 1 "Transcode function returned with status: $transcode_status"
        if [ $transcode_status -eq 0 ]; then
            remove_from_master_list "$file"
        else
            logthis 2 "Transcode may have failed for file: $file"
        fi
        logthis 2 "Completed file ${current_file}/${total_files}"
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        average_time_per_file=$((elapsed_time / current_file))
        remaining_files=$((total_files - current_file))
        estimated_remaining_time=$((average_time_per_file * remaining_files))
        estimated_completion_time=$(date -d "+${estimated_remaining_time} seconds" '+%Y-%m-%d %H:%M:%S')
        # Calculate elapsed time components
        elapsed_days=$((elapsed_time / 86400))
        elapsed_hours=$(( (elapsed_time % 86400) / 3600 ))
        elapsed_minutes=$(( (elapsed_time % 3600) / 60 ))
        elapsed_seconds=$((elapsed_time % 60))

        echo "Elapsed time:              ${elapsed_days}d ${elapsed_hours}h ${elapsed_minutes}m ${elapsed_seconds}s"
        echo "Estimated time:            ${estimated_days}d ${estimated_hours}h ${estimated_minutes}m ${estimated_seconds}s"
        echo "Estimated completion time: ${estimated_completion_time}"
    done

    logthis 3 "Processing finished. Processed: ${current_file}/${total_files}"
}

# Function to handle the 'convertfile' command
convert_single_file() {
    local file_path="$1"
    transcode_file "$file_path"
}

# Function to handle the 'convertdir' command
convert_directory() {
    local directory="$1"
    local convertdir_list=$(mktemp)
    logthis 2 "Converting all files in directory: ${directory} and its immediate subdirectories"
    find "$directory" -mindepth 1 -maxdepth 2 -type f ! -name "*-AV1.mp4" -not -path "*/.Trash-*" -print0 | while IFS= read -r -d '' file; do
        if is_valid_media_file "$file"; then
          printf '%s\n' "$file" >> "$convertdir_list"
        fi
    done
    
    mapfile -t filtered_files < "$convertdir_list"
    total_files=${#filtered_files[@]}
    current_file=0
    for file in "${filtered_files[@]}"; do
        current_file=$((current_file + 1))
        logthis 2 "Processing file ${current_file}/${total_files}"
        transcode_file "$file"
        transcode_status=$?
        logthis 1 "Transcode function returned with status: $transcode_status"
        if [ $transcode_status -ne 0 ]; then
            logthis 2 "Transcode may have failed for file: $file"
            exit 1 
        fi
    done

    rm -f "$convertdir_list"  # Clean up temporary file
}

# Main script logic
config

command="$1"
shift

case "$command" in
    generate)
        if [[ -d "$1" ]]; then
            generate_master_list "$1"
        else
            echo "Error: Directory not found."
            exit 1
        fi
        ;;
    convert)
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                --starts-with=*) starts_with="${1#*=}"; shift ;;
                *) echo "Unknown option: $1"; exit 1 ;;
            esac
        done
        convert_from_master_list
        ;;
    convertfile)
        if [[ -f "$1" ]]; then
            convert_single_file "$1"
        else
            echo "Error: File not found."
            exit 1
        fi
        ;;
    convertdir)
        if [[ -d "$1" ]]; then
            convert_directory "$1"
        else
            echo "Error: Directory not found."
            exit 1
        fi
        ;;
    *)
        echo "Usage: av1encode {generate <dir> | convert [--starts-with=x] | convertfile <filepath> | convertdir <directory>}"
        exit 1
        ;;
esac

# Function to handle SIGINT (CTRL-C)
handle_sigint() {
    logthis 4 "SIGINT received. Exiting script immediately."
    exit 1
}

# Set trap to call handle_sigint function on SIGINT
trap handle_sigint SIGINT

# Set trap to call worker_cleanup function on script exit
trap worker_cleanup EXIT







