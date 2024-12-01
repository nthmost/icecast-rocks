#!/bin/bash

BASE_DIR="/home/liquidsoap"
SCRIPT_DIR="$BASE_DIR/scripts"
PODCAST_DIR="$BASE_DIR/podcasts"
MUSIC_DIR="$BASE_DIR/music"
LOG_DIR="/var/log/liquidsoap"

# Download script for RNaG podcasts
cat > "$SCRIPT_DIR/fetch_rnag.sh" << 'EOF'
#!/bin/bash
PODCAST_DIR="/home/liquidsoap/podcasts"
FEEDS=(
  "https://www.rte.ie/radio/rnag/podcast/podcast_example.xml"
)

for feed in "${FEEDS[@]}"; do
  wget -q -O - "$feed" | grep -o 'http[s]\?://[^"]*\.mp3' | while read url; do
    filename=$(basename "$url")
    if [ ! -f "$PODCAST_DIR/$filename" ]; then
      wget -q -P "$PODCAST_DIR" "$url"
    fi
  done
done

find "$PODCAST_DIR" -type f -mtime +30 -delete
EOF

# Liquidsoap script
cat > "$SCRIPT_DIR/irish_radio.liq" << 'EOF'
#!/usr/bin/liquidsoap

set("log.file.path", "/var/log/liquidsoap/irish_radio.log")
set("log.stdout", true)

music = playlist("/home/liquidsoap/music")
podcasts = playlist("/home/liquidsoap/podcasts")
radio = rotate(weights=[1, 2], [music, podcasts])

output.icecast(
  %mp3,
  host="localhost",
  port=8000,
  password="hackme",
  mount="irish.mp3",
  name="Irish Language Radio",
  description="Irish Language Podcasts and Music",
  genre="Irish",
  radio
)
EOF

chmod +x "$SCRIPT_DIR/fetch_rnag.sh"
chmod +x "$SCRIPT_DIR/irish_radio.liq"
