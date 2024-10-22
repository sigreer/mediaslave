#!/bin/bash
echo "Script invoked"
# Check if aria2c is installed
if ! command -v aria2c &> /dev/null; then
    echo "aria2c could not be found. Please install it."
    exit 1
fi

# Check if transmission-show is installed
if ! command -v transmission-show &> /dev/null; then
    echo "transmission-show could not be found. Please install it."
    exit 1
fi
declare magnet
# Source .env file if it exists
if [ -f "$HOME/.env-torrent2debrid" ]; then
    echo "Sourcing .env file"
    source "$HOME/.env-torrent2debrid"
fi

if [ -n "$OUTPUT_DIR" ]; then
    download_dir="${OUTPUT_DIR%/}"
    echo "using ${download_dir}"
fi
if [ -n "$REALDEBRID_APIKEY" ]; then
    authtoken="$REALDEBRID_APIKEY"
else
    echo "No API token found. Please either create a .secret file or export the REALDEBRID_APIKEY environment variable."
    exit 1
fi


# Read the API token from the file


realdebrid_url="https://api.real-debrid.com/rest/1.0"

generate_magnet_link() {
    torrent_file="$1"

    # Check if the file exists
    if [ ! -f "$torrent_file" ]; then
        echo "Torrent file not found!"
        exit 1
    fi

    # Extract the info hash from the torrent file using transmission-show
    info_hash=$(transmission-show "$torrent_file" | grep "Hash v1:" | awk '{print $3}')

    if [ -z "$info_hash" ]; then
        echo "Could not extract the info hash!"
        exit 1
    fi

    # Create the magnet link
    magnet="magnet:?xt=urn:btih:$info_hash&dn=$(basename "$torrent_file" .torrent)"
    echo "Magnet link: $magnet"
}

send_magnet_to_realdebrid() {
    local magnet_link="$1"
    local response
    local torrent_id
    local torrent_info_uri

    response=$(curl -s -X POST "$realdebrid_url/torrents/addMagnet" \
        -H "Authorization: Bearer $authtoken" \
        -d "magnet=$magnet_link")

    if [[ "$response" == *"error"* ]]; then
        echo "Failed to send magnet link to Real-Debrid: $response"
        exit 1
    else
        echo "Magnet link successfully sent to Real-Debrid: $response"
        
        # Extract the torrent ID and URI from the response
        torrent_id=$(echo "$response" | jq -r '.id')
        torrent_info_uri=$(echo "$response" | jq -r '.uri')

        # Send a GET request to the URI
        get_torrent_info "$torrent_id" "$torrent_info_uri"
    fi
}

get_torrent_info() {
    local torrent_id="$1"
    local uri="$2"
    local info_response
    local file_id
    local file_size

    info_response=$(curl -s -X GET "$uri" \
        -H "Authorization: Bearer $authtoken")

    # Parse the response to get the ID and size of the .mkv or .mp4 file
    file_id=$(echo "$info_response" | jq -r '.files[] | select(.path | endswith(".mkv") or endswith(".mp4")) | .id')
    file_size=$(echo "$info_response" | jq -r '.files[] | select(.path | endswith(".mkv") or endswith(".mp4")) | .bytes')

    if [ -n "$file_id" ]; then
        select_file "$torrent_id" "$file_id" "$file_size"
    else
        echo "No .mkv or .mp4 file found in the torrent."
    fi
}

select_file() {
    local torrent_id="$1"
    local file_id="$2"
    local expected_file_size="$3"
    local select_response
    local torrent_info_response
    local links

    # Select the file
    select_response=$(curl -s -X POST "$realdebrid_url/torrents/selectFiles/$torrent_id" \
        -H "Authorization: Bearer $authtoken" \
        -d "files=$file_id")

    echo "File selection response: $select_response"

    # Immediately query the torrent info to get the download links
    torrent_info_response=$(curl -s -X GET "$realdebrid_url/torrents/info/$torrent_id" \
        -H "Authorization: Bearer $authtoken")

    echo "Torrent info response: $torrent_info_response"

    # Extract links from the torrent info response
    links=$(echo "$torrent_info_response" | jq -r '.links[]')

    # Send each link to the /unrestrict/link endpoint
    for link in $links; do
        unrestrict_link "$link" "$expected_file_size"
    done
}

unrestrict_link() {
    local link="$1"
    local expected_file_size="$2"
    local unrestrict_response
    local download_link

    unrestrict_response=$(curl -s -X POST "$realdebrid_url/unrestrict/link" \
        -H "Authorization: Bearer $authtoken" \
        -d "link=$link")

    echo "Unrestricted link response: $unrestrict_response"

    # Extract the download link from the response
    download_link=$(echo "$unrestrict_response" | jq -r '.download')

    if [ -n "$download_link" ]; then
        echo "Downloading file from: $download_link"
        download_file "$download_link" "$output_dir" "$expected_file_size"
    else
        echo "Failed to retrieve download link."
    fi
}

download_file() {
    local download_link="$1"
    local output_dir="$2"
    local expected_file_size="$3"
    local output_file

    # Extract the filename from the download link
    output_file=$(basename "$download_link")

    # Remove special characters from the filename
    output_file=$(echo "$output_file" | tr -d '[]%')

    # Use curl or wget to download the file to the specified directory
    curl -o "$output_dir/$output_file" "$download_link" || wget -O "$output_dir/$output_file" "$download_link"

    # Check if the downloaded file size matches the expected file size
    file_size=$(stat -c%s "$output_dir/$output_file")
    if [ "$file_size" -eq "$expected_file_size" ]; then
        echo "File size matches the expected size. Torrent file will be deleted."
        rm -f "$torrent_file"
    else
        echo "File size does not match the expected size. Torrent file will not be deleted."
    fi
}

# Main logic
if [ -z "$1" ]; then
    echo "Usage: $0 <torrent_url_or_local_file> [output_directory]"
    exit 1
fi

input="$1"
output_dir="${2:-$download_dir}"  # Use the second argument or fallback to download_dir

if [ -f "$input" ]; then
    generate_magnet_link "$input"
    send_magnet_to_realdebrid "$magnet"
else
    torrent_url="$input"
    torrent_file=$(basename "$torrent_url")
    aria2c -o "$torrent_file" "$torrent_url"
    generate_magnet_link "$torrent_file"
    send_magnet_to_realdebrid "$magnet"
fi
