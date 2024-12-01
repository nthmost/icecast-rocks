#!/bin/bash

# Directory structure
mkdir -p /var/lib/liquidsoap/rnag/podcasts
mkdir -p /var/lib/liquidsoap/irish_music
mkdir -p /var/lib/liquidsoap/scripts

# Download script for RNaG podcasts
cat > /var/lib/liquidsoap/scripts/fetch_rnag.sh << 'EOF'
#!/bin/bash
PODCAST_DIR="/var/lib/liquidsoap/rnag/podcasts"
# Add RNaG RSS feeds - you'll need to fill these in
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

# Clean files older than 30 days
find "$PODCAST_DIR" -type f -mtime +30 -delete
EOF

# Liquidsoap script
cat > /var/lib/liquidsoap/scripts/irish_radio.liq << 'EOF'
#!/usr/bin/liquidsoap

# Settings
set("log.file.path", "/var/log/liquidsoap/irish_radio.log")
set("log.stdout", true)

# Music playlist
music = playlist("/var/lib/liquidsoap/irish_music")

# Podcasts playlist
podcasts = playlist("/var/lib/liquidsoap/rnag/podcasts")

# Rotate between music and podcasts
radio = rotate(weights=[1, 2], [music, podcasts])

# Stream settings
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

# Set permissions
chmod +x /var/lib/liquidsoap/scripts/fetch_rnag.sh
chmod +x /var/lib/liquidsoap/scripts/irish_radio.liq

# Create crontab entry
(crontab -l 2>/dev/null; echo "0 */4 * * * /var/lib/liquidsoap/scripts/fetch_rnag.sh") | crontab -
