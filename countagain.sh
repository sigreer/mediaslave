#!/bin/bash

# Check if both directory path and output path are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Please provide both an input directory and an output path:"
  echo "countagain <library_path> <file_output_path>"
  exit 1
fi

# Convert relative paths to absolute paths
movies_path=$(realpath "${1%/}")
output_path=$(realpath "${2%/}")
output_file=countagain_allmovies.csv
media_extensions="mp4|avi|mov|mkv|m4a|flv|wmv|mpg|mpeg|webm"
converted_files_list=countagain_av1converted_files.csv
unconverted_files_list=countagain_unconverted_files.csv
empty_dirs_list=countagain_empty_dirs.csv
initial_dir_size=$(cat "${output_path}"/.countagain_first_size)
last_dir_size=$(cat "${output_path}"/.countagain_last_size)
current_dir_size=$(du -sb "${movies_path}" 2>/dev/null | cut -f1)
dirsize_calculated() {
  input_value=$1
  output_value=$(echo "$((input_value / 1000000))")
  echo "$output_value"
}

initial_dir_size_calculated=$(dirsize_calculated "$initial_dir_size")
last_dir_size_calculated=$(dirsize_calculated "$last_dir_size")
current_dir_size_calculated=$(dirsize_calculated "$current_dir_size")
initial_dir_size_formatted=$(printf "%'d" "$initial_dir_size_calculated")
last_dir_size_formatted=$(printf "%'d" "$last_dir_size_calculated")
current_dir_size_formatted=$(printf "%'d" "$current_dir_size_calculated")
size_diff_mb_initial_formatted=$(printf "%'d" "$size_diff_mb_initial")
size_diff_mb_last_formatted=$(printf "%'d" "$size_diff_mb_last")
size_diff_mb_initial=$(( (initial_dir_size - current_dir_size) / 1000000 ))
size_diff_mb_initial_formatted=$(printf "%'d" "$size_diff_mb_initial")
size_diff_percent_initial=$(awk "BEGIN {printf \"%.2f\", 100 - (($current_dir_size / $initial_dir_size) * 100)}")
size_diff_mb_last=$(( ( last_dir_size - current_dir_size ) / 1000000 ))
size_diff_mb_last_formatted=$(printf "%'d" "$size_diff_mb_last")
size_diff_percent_last=$(awk "BEGIN {printf \"%.2f\", (( ($last_dir_size - $current_dir_size) / $last_dir_size) * 100)}")


find "$movies_path" -type f -regextype posix-extended -regex ".*\.($media_extensions)$" > "$output_file" 2>/dev/null
find "$movies_path" -mindepth 1 -maxdepth 1 -type d -empty > "$empty_dirs_list" 2>/dev/null
cat "${output_file}" | grep AV1 > "$converted_files_list"
cat "${output_file}" | grep -v AV1 > "$unconverted_files_list"
total_files=$(cat "${output_file}" | wc -l)
total_dirs=$(ls "$movies_path" | wc -l)
empty_dirs=$(cat "${empty_dirs_list}" | wc -l)
converted_total=$(cat "${converted_files_list}" | wc -l)
unconverted_total=$(cat "${unconverted_files_list}" | wc -l)
percentage_converted="0.00"
percentage_converted=$(awk "BEGIN {printf \"%.2f\", ($converted_total / $total_files) * 100}")


echo ""
echo "-------------------------------------------------------"
echo    "  MOVIES:"
echo    "  Total Dirs:                  ${total_dirs}"
echo    "  Empty Dirs:                  ${empty_dirs}"
echo ""
echo    "  Total video files            ${total_files}"
echo -e "  Unconverted files:           \e[31m${unconverted_total}\e[0m"
echo -e "  AV1 converted files:         \e[36m${converted_total}     ${percentage_converted}%\e[0m"
echo ""
printf "  Initial Library Size:        %'10s MB\n" "${initial_dir_size_formatted}"
printf "  Last Library Size:           %'10s MB\n" "${last_dir_size_formatted}"
printf "  Current Library Size:        %'10s MB\n" "${current_dir_size_formatted}"
printf "  Difference vs Initial:       %'10s MB %10s%%\n" "${size_diff_mb_initial_formatted}" "${size_diff_percent_initial} smaller"
printf "  Difference vs Last:          %'10s MB %10s%%\n" "${size_diff_mb_last_formatted}" "${size_diff_percent_last} smaller"
echo ""
echo    "  Converted file list:         ${converted_files_list}"
echo    "  Unconverted file list:       ${unconverted_files_list}"
echo    "  All files list:              ${output_file}"
echo    "  Empty dir list:              ${empty_dirs_list}"
echo    "-------------------------------------------------------"
