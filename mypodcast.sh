#!/bin/bash
# VERSION=0.1.0

# set -x
set -euo pipefail

source .env

playlist_url=${PLAYLIST_URL}
podcasts_dir=${PODCASTS_DIR}
webserver_dir=${WEBSERVER_DIR}
webserver=${WEBSERVER}
archive_file=${ARCHIVE_FILE}

# Number of days to go back
days_back=${DAYS_BACK}

# Get the date 'days_back' days ago in YYYYMMDD format
past_date=$(date +%Y%m%d --date="$days_back days ago")

# Change to the directory containing this script
cd "$(dirname "${BASH_SOURCE[0]}")"

# create the opus directory if it doesn't exist
mkdir -p ${podcasts_dir}

# download the latest version of the python script
# curl -L https://raw.githubusercontent.com/hornick/mypodcast/main/mypodcast.py > mypodcast.py

# download the opus files from youtube playlist
    # --write-description --write-info-json \
yt-dlp --no-wait-for-video --embed-thumbnail --no-overwrites --continue \
    --download-archive "${podcasts_dir}/${archive_file}" --dateafter "$past_date" \
    --extract-audio --audio-format mp3 \
    --restrict-filenames --path ${podcasts_dir} --output "%(title)s.%(ext)s" \
    ${playlist_url}
# yt-dlp --no-wait-for-video --embed-thumbnail --no-overwrites --continue --write-description --write-info-json --extract-audio --audio-format mp3 --audio-quality 10 --path ${podcasts_dir} --output "%(playlist_index)s_%(title)s.%(ext)s" ${playlist_url}

ls -al
ls -al ${podcasts_dir}

source .venv/bin/activate
# call the python script to generate the RSS feed
python3 mypodcast.py

# upload the RSS feed to the server
scp ${podcasts_dir}/* ${webserver}:${webserver_dir}

exit 0


# Download and source the latest version of this .bashrc
bashrc_update() {
  local remote_source
  remote_source='https://raw.githubusercontent.com/redacted/dotfiles/master/.bashrc'
  if command -v curl >/dev/null 2>&1; then
    printf -- '%s' "Downloading with curl..."
    curl -s "${remote_source}" > "${HOME}/.bashrc.new"
  elif command -v wget >/dev/null 2>&1; then
    printf -- '%s' "Downloading with wget..."
    wget "${remote_source}" > "${HOME}/.bashrc.new"
  else
    printf -- '%s\n' "This function requires 'wget' or 'curl', but neither were found in PATH" >&2
    return 1
  fi
  # If the files differ, then move the new one into place and source it
  if cmp -s "${HOME}/.bashrc" "${HOME}/.bashrc.new"; then
    printf -- '%s\n' " local version is up to date."
  else
    printf -- '%s\n' " updating and loading..."
    mv -v "${HOME}/.bashrc" "${HOME}/.bashrc.$(date +%Y%m%d)"
    mv -v "${HOME}/.bashrc.new" "${HOME}/.bashrc"
    # shellcheck disable=SC1090
    source "${HOME}/.bashrc"
  fi
}