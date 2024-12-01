#!/bin/bash
PODCAST_DIR="/home/liquidsoap/podcasts"
LOG_FILE="/var/log/liquidsoap/rnag.log"

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log() {
  echo "$(timestamp) $1" >> "$LOG_FILE"
}

FEEDS=(
  "https://www.rte.ie/radio1/podcast/podcast_barrscealta.xml"
  "https://www.rte.ie/radio1/podcast/podcast_bladhairernag.xml"
  "http://www.rte.ie/radio1/podcast/podcast_adhmhaidin.xml"
)

HEADERS=(
  --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
  --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
)

for feed in "${FEEDS[@]}"; do
  log "Checking feed: $feed"
  wget "${HEADERS[@]}" -q -O - "$feed" | grep -o 'http[s]\?://[^"]*\.mp3' | while read url; do
    filename=$(basename "$url")
    if [ ! -f "$PODCAST_DIR/$filename" ]; then
      wget "${HEADERS[@]}" -q -P "$PODCAST_DIR" "$url"
      log "Downloaded: $filename"
    else
      log "Skipped existing file: $filename"
    fi
  done
done

log "Cleaning files older than 30 days..."
find "$PODCAST_DIR" -type f -mtime +30 -delete -print | while read removed; do
  log "Removed old file: $removed"
done
