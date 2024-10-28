#!/bin/bash
set -x
set -euo pipefail

source .env

playlist_url=${PLAYLIST_URL}
opus_dir=${OPUS_DIR}
webserver_dir=${WEBSERVER_DIR}
webserver=${WEBSERVER}

# Number of days to go back
days_back=7

# Get the date 'days_back' days ago in YYYYMMDD format
past_date=$(date +%Y%m%d --date="$days_back days ago")

# Change to the directory containing this script
cd "$(dirname "${BASH_SOURCE[0]}")"

# create the opus directory if it doesn't exist
mkdir -p ${opus_dir}

# download the latest version of the python script
# curl -L https://raw.githubusercontent.com/hornick/mypodcast/main/mypodcast.py > mypodcast.py

# download the opus files from youtube playlist
    # --write-description --write-info-json \
yt-dlp --no-wait-for-video --embed-thumbnail --no-overwrites --continue \
    --dateafter "$past_date" \
    --extract-audio --audio-format mp3 \
    --restrict-filenames --path ${opus_dir} --output "%(title)s.%(ext)s" \
    ${playlist_url}
# yt-dlp --no-wait-for-video --embed-thumbnail --no-overwrites --continue --write-description --write-info-json --extract-audio --audio-format mp3 --audio-quality 10 --path ${opus_dir} --output "%(playlist_index)s_%(title)s.%(ext)s" ${playlist_url}

ls -al
ls -al ${opus_dir}

source .venv/bin/activate
# call the python script to generate the RSS feed
python3 mypodcast.py

# upload the RSS feed to the server
scp ${opus_dir}/* ${webserver}:${webserver_dir}
