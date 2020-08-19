#!/bin/bash
date=$(date +"%d-%m-%Y-%H%M")
LogFile=/config/log/postProcess.$date.log
IFS=$(echo -en "\n\b")
export LD_LIBRARY_PATH=/usr/local/lib
ts="$(basename $1)"
map="$(dirname $1)"
mp4="${ts%.*}.mp4"
mp4="$(basename $mp4)"
mkv="${ts%.*}.mkv"
mkv="$(basename $mkv)"
srt="${ts%.*}.srt"
srt="$(basename $srt)"
exec 3>&1 1>>${LogFile} 2>&1
mediainfo --Inform="Text;subs=%Format%\n" "$1" | head -c 8 >> "$1".txt
source "$1".txt
ccextractor "$1" -o "$map/$srt"
if [ $subs = "DVB" ] ; then
    ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$1" -vf 'format=nv12|vaapi,hwupload,deinterlace_vaapi' -c:v hevc_vaapi -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s copy "$map/$mkv"
else
    if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +500c 2>/dev/null) ]] ; then
        ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$1" -i "$map/$srt" -vf 'format=nv12|vaapi,hwupload,deinterlace_vaapi' -c:v hevc_vaapi -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s mov_text "$map/$mp4"
    else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
        ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "$1" -vf 'format=nv12|vaapi,hwupload,deinterlace_vaapi' -c:v hevc_vaapi -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
    fi
fi
if [ -f "$map/$srt" ] ; then
rm "$map/$srt"
fi
rm "$1".txt
#SEDIF
