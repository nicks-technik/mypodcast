#!/bin/bash
# VERSION=0.1.0

set -x
set -euo pipefail

# Change to the directory containing this script
cd "$(dirname "${BASH_SOURCE[0]}")"

# load the .env file if it exists
if [ -f .env ]; then
    echo "Loading environment variables from .env file"
    source .env
fi

# variables
script_url=${SCRIPT_URL:-"https://raw.githubusercontent.com/nicks-technik/mypodcast.sh"}
# playlist_url=${PLAYLIST_URL:-"https://www.youtube.com/playlist?list=PL-56i5fRQDILa-YSZl--Qr47IQvv2qDQC"}
podcasts_dir=${PODCASTS_DIR:-"podcasts_files"}
webserver_dir=${WEBSERVER_DIR:-"~/config/webservers"}
webserver=${WEBSERVER:-"server"}
archive_file=${ARCHIVE_FILE:-"archiveIDs.txt"}
channels_file=${CHANNELS_FILE:-"channels.cfg"}

# Number of days to go back
days_back=${DAYS_BACK:-365}

# Get the date 'days_back' days ago in YYYYMMDD format
past_date=$(date +%Y%m%d --date="$days_back days ago")

function log() {
    local message="$1"
    local indicator="${2:-INFO}" # Default to "INFO" if not provided

    case "$indicator" in
    "INFO")
        echo -e "\033[0;32mINFO: $message\033[0m"
        ;;
    "DEBUG")
        echo -e "\033[0;34mDEBUG: $message\033[0m"
        ;;
    "NORMAL")
        echo -e "\033[0;31mERROR: $message\033[0m"
        ;;
    "ERROR")
        echo -e "\033[0;31mERROR: $message\033[0m"
        ;;
    *)
        echo "Unknown indicator: $indicator"
        ;;
    esac
}

# ... rest of your script ...

# Example usage:
log "Starting script execution"
log "Downloading podcasts for channel: $past_date", "DEBUG"
log "An error occurred during download", "ERROR"

download_yt-dlp() {
    # create the channel directory if it doesn't exist
    mkdir -p "$channel_dir"
    yt-dlp --no-wait-for-video --embed-thumbnail --no-overwrites --continue \
        --download-archive "${podcasts_dir}/${archive_file}" --dateafter "$past_date" \
        --extract-audio --audio-format mp3 \
        --restrict-filenames --path ${podcasts_dir} --output "%(title)s.%(ext)s" \
        ${yt_url}
}
generate_podcast_rss() {
    source .venv/bin/activate
    # call the python script to generate the RSS feed
    python3 mypodcast.py

}
upload_podcasts() {
    # upload the RSS feed to the server
    scp -r ${podcasts_dir}/* ${webserver}:${webserver_dir}
}

load_youtube_config() {
    # declare -a channels

    # while IFS= read -r channel yt_url; do
    #     channel_dir="$podcasts_dir/$channel"
    #     log "Active channel: ${channel} and yt_url: ${yt_url}"
    #     # download_yt-dlp
    #     log "downloded podcasts for channel: $channel", "DEBUG"
    #     download_yt-dlp
    #     log "downloded podcasts for channel: $channel", "DEBUG"
    #     # generate_podcast_rss
    #     log "generated podcast.xml for channel: $channel", "DEBUG"
    #     # upload_podcasts
    #     log "Finished uploading podcasts for channel: $channel"
    # done <channels.cfg

    # cat "$channels_file"

    # Read the config file and process each line
    while IFS="," read -r channel_name channel_url; do
        echo "Channel Name: $channel_name"
        echo "Channel URL: $channel_url"

        echo $channel_name
        echo $channel_url

        log "Active channel: ${channel_name} and yt_url: ${channel_url}"
        # download_yt-dlp
        log "downloded podcasts for channel: $channel_name", "DEBUG"
        download_yt-dlp
        log "downloded podcasts for channel: $channel_name", "DEBUG"
        # generate_podcast_rss
        log "generated podcast.xml for channel: $channel_name", "DEBUG"
        # upload_podcasts
        log "Finished uploading podcasts for channel: $channel_name"

        # else
        #     log "Invalid line format in config file: $line" "ERROR"
        # fi
    done <"$channels_file"

}

log ""

load_youtube_config

exit 0

##########################
# download the latest version of the python script
# curl -L https://raw.githubusercontent.com/hornick/mypodcast/main/mypodcast.py > mypodcast.py

function self_update_script {
    # get the name of the script
    # script_name=$(basename "${BASH_SOURCE[0]}")
    # abs_script_path=$(readlink -f "$script_location")
    script_location="${BASH_SOURCE[@]}"
    tmp_file=$(mktemp -p "" "XXXXX.sh")

    if command -v curl >/dev/null 2>&1; then
        printf -- '%s' "Downloading with curl..."
        curl -s "${script_url}" >"${tmp_file}"
    elif command -v wget >/dev/null 2>&1; then
        printf -- '%s' "Downloading with wget..."
        wget "${script_url}" >"${tmp_file}"
    else
        printf -- '%s\n' "This function requires 'wget' or 'curl', but neither were found in PATH" >&2
        return 1
    fi

    # If the files differ, then move the new one into place and source it
    if cmp -s "${script_location}" "${tmp_file}"; then
        printf -- '%s\n' " local version is up to date."
    else
        printf -- '%s\n' "Updating script \e[31;1m%s\e[0m -> \e[32;1m%s\e[0m\n "
        mv -v "${abs_script_path}/" "${script_location}.$(date +%Y%m%d)"
        mv -v "${tmp_file}" "${script_location}" || printf "Unable to update the script"
    fi

}
