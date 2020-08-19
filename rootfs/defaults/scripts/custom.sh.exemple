#!/bin/bash
date=$(date +"%d-%m-%Y-%H%M")
LogFile=/config/log/postProcess.$date.log
IFS=$(echo -en "\n\b")
export LD_LIBRARY_PATH=/usr/local/lib
mkv="$(basename $1)"
map="$(dirname $1)"
mp4="${mkv%.*}.mp4"
mp4="$(basename $mp4)"
srt="${mkv%.*}.srt"
srt="$(basename $srt)"
exec 3>&1 1>>${LogFile} 2>&1
ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$1" -vf 'format=nv12|vaapi,hwupload,deinterlace_vaapi' -c:v hevc_vaapi -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
#SEDIF