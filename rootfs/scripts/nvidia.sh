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
mediainfo --Inform="Video;codec_name=%Format%" "$1" | head -c 14 >> "$1".txt
source "$1".txt
if [ $codec_name = "AVC" ] ; then
ffmpeg -hwaccel cuvid -c:v h264_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -filter_complex "hwdownload,format=nv12,format=yuv420p" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
fi
if [ $codec_name = "MPE" ] ; then
ffmpeg -hwaccel cuvid -c:v mpeg2_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
fi
if [ $codec_name != "AVC" ] && [ $codec_name != "MPE" ] ; then
ffmpeg -hwaccel nvdec -i "$1" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
fi
rm "$1".txt
#SEDIF
