#!/bin/bash
date=$(date +"%d-%m-%Y-%H%M")
LogFile=/config/log/postProcess.$date.log
IFS=$(echo -en "\n\b")
export LD_LIBRARY_PATH=/usr/local/lib

INPUT="$1"
OUTPUT="$2"
OUTPUTSRT="$3"

exec 3>&1 1>>${LogFile} 2>&1
mediainfo --Inform="Video;codec_name=%Format%" "$INPUT" | head -c 14 >> "$OUTPUT".txt
source "$OUTPUT".txt
ccextractor "$INPUT" -o "$OUTPUTSRT"
ffmpeg -i "$INPUT" -hide_banner -loglevel info -max_muxing_queue_size 512 -c:v libx265 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$OUTPUT"
rm "$OUTPUT".txt
