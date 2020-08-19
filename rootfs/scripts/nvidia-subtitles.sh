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
mediainfo --Inform="Video;codec_name=%Format%" "$1" | head -c 14 >> "$1".txt
echo -e >> "$1".txt
mediainfo --Inform="Text;subs=%Format%" "$1" | head -c 8 >> "$1".txt
source "$1".txt
ccextractor "$1" -o "$map/$srt"
if [ $codec_name = "AVC" ] ; then
    if [ $subs = "DVB" ] ; then
	    ffmpeg -hwaccel cuvid -c:v h264_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -filter_complex "hwdownload,format=nv12,format=yuv420p" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s copy "$map/$mkv"
	else
        if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +500c 2>/dev/null) ]] ; then
            ffmpeg -hwaccel cuvid -c:v h264_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -filter_complex "hwdownload,format=nv12,format=yuv420p" -i "$map/$srt" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s mov_text "$map/$mp4"
        else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
            ffmpeg -hwaccel cuvid -c:v h264_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -filter_complex "hwdownload,format=nv12,format=yuv420p" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
        fi
	fi
fi
if [ $codec_name = "MPE" ] ; then
    if [ $subs = "DVB" ] ; then
	    ffmpeg -hwaccel cuvid -c:v mpeg2_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s copy "$map/$mkv"
	else
        if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +500c 2>/dev/null) ]] ; then
            ffmpeg -hwaccel cuvid -c:v mpeg2_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -i "$map/$srt" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s mov_text "$map/$mp4"
        else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
            ffmpeg -hwaccel cuvid -c:v mpeg2_cuvid -deint 2 -drop_second_field 1 -surfaces 10 -i "$1" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
        fi
    fi
fi
if [ $codec_name != "AVC" ] && [ $codec_name != "MPE" ] ; then
    if [ $subs = "DVB" ] ; then
	    ffmpeg -hwaccel nvdec -i "$1" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s copy "$map/$mkv"
	else
        if [ -f "$map/$srt" ] && [[ $(find "$map/$srt" -type f -size +500c 2>/dev/null) ]] ; then
            ffmpeg -hwaccel nvdec -i "$1" -i "$map/$srt" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k -c:s mov_text "$map/$mp4"
        else echo "*** CCextractor couldn't find Closed Captions. No Subtitles will be added...***"
            ffmpeg -hwaccel nvdec -i "$1" -c:v hevc_nvenc -rc:v vbr -rc-lookahead:v 32 -brand mp42 -ac 2 -c:a libfdk_aac -b:a 128k "$map/$mp4"
        fi
    fi
fi
if [ -f "$map/$srt" ] ; then
rm "$map/$srt"
fi
rm "$1".txt
#SEDIF