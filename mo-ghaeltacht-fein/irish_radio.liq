#!/usr/bin/liquidsoap

set("log.file.path", "/var/log/liquidsoap/stream.log")
set("log.stdout", true)

# Create playlist from directory
podcasts = playlist(
  "/home/liquidsoap/podcasts",
  mode="random",
  reload=3600,
  reload_mode="round"
)

# Make the stream safe
podcasts = mksafe(podcasts)

# Output to Icecast
output.icecast(
  %mp3,
  host="localhost",
  port=8000,
  password="Troph33Wyfe",
  mount="ulster.mp3",
  name="Ulster Irish Radio",
  description="Recent Ulster Irish Language Programs",
  podcasts
)
