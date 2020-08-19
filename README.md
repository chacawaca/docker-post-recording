# docker-recordings-transcoder

Watches for .ts files in /watch and converts them to h265 .mp4 files automatically.  
Tested with Plex and Emby recordings.

Example run

```shell
docker run -d \
    --name=recordings-converter \
    -v /home/user/videos:/watch:rw \
    -v /docker/appdata/recordings-transcoder:/config:rw \
    -e ENCODER=software \
    -e SUBTITLES=0 \
    -e DELETE_TS=0 \
    -e PUID=99 \
    -e PGID=100 \
    -e UMASK=000 \
    djaydev/recordings-converter
```

Where:

- `/docker/appdata/recordings-converter`: This is where the application stores its configuration, log and any files needing persistency.  Location to add a custom script for video conversion named custom.sh
- `/home/user/videos`: This location contains .ts files that need converting.  
- `ENCODER`: options are "intel" "nvidia" "software" "custom" explained below
- `SUBTITLES`: Include subtitles from the original .ts, 0 = no, 1 = yes. **If converting DVB recordings please see [below](#dvb-recordings-and-subtitles)**
- `DELETE_TS`: After converting remove the original .ts recording file. 0 = no, 1 = yes. **USE DELETE_TS=0 UNTIL YOU'RE SURE IT WORKS WITH YOUR VIDEO RECORDINGS.**
- `PUID`: ID of the user the application runs as.
- `PGID`: ID of the group the application runs as.
- `UMASK`: Mask that controls how file permissions are set for newly created files.

- ENCODER=intel  
This options runs a script to convert the .ts video using ffmpeg with vaapi hardware acceleration enabled. It requires `--device /dev/dri:/dev/dri` (and permissions on /dev/dri given to PUID user) to access the intel GPU in the docker container. Tries to convert any codec to h265 .mp4 files. If you have any issues with AVC/h264 recordings and Intel, please open an issue with the postProcess log and in the meantime switch to ENCODER=software temporarily.

- ENCODER=nvidia  
This options runs a script to convert the .ts video using ffmpeg with Nvidia nvenc hardware acceleration enabled. It requires `--runtime=nvidia` and `-e NVIDIA_DRIVER_CAPABILITIES=all` to access the Nvidia GPU in the docker container. Tries to convert any codec to h265 .mp4 files. If you have any issues with AVC/h264 recordings and Nvidia, please open an issue with the postProcess log and in the meantime switch to ENCODER=software temporarily.

- ENCODER=software  
This options runs a script to convert the .ts video using ffmpeg with software encoding enabled. Very CPU intensive but results in the best file size to video quality ratio.
Tries to convert any codec to h265 .mp4 files.

- ENCODER=custom  
This option runs your script to convert the .ts video using ffmpeg however you choose. With this option please include your script named "custom.sh" in the mapped /config folder.  

## DVB Recordings and Subtitles

If your Live TV recordings are from DVB channels and you set subtitles to 1=yes, the recordings will be converted to h265 with the DVB subtitles included, but the container will be .mkv instead of .mp4. This is the only condition where mkv is used, and it's because mp4 does not support DVB subtitles.  One benefit of this is mkv will produce a slightly smaller file size than mp4 at the same quality.  If you prefer to have all mp4 files then switch subtitles to 0 and possibly utilize an external subtitle source such as [Caption](https://getcaption.co/) or [Bazarr](https://www.bazarr.media/).

## Unraid Users

**[Help with Intel](https://forums.unraid.net/topic/77943-guide-plex-hardware-acceleration-using-intel-quick-sync/)**  
Intel GPU Use  
Edit your go file to include:  
modprobe i915, save and reboot, then  
add --device=/dev/dri to "extra parameters" (switch on advanced view)  

**[Help with Nvidia](https://forums.unraid.net/topic/77813-plugin-linuxserverio-unraid-nvidia/)**  
Nvidia GPU Use  
Using the Unraid Nvidia Plugin to install a version of Unraid with the Nvidia Drivers installed and  
add --runtime=nvidia to "extra parameters" (switch on advanced view) and  
copy your GPU UUID to NVIDIA_VISIBLE_DEVICES.  

## projects used

www.github.com/jlesage/docker-handbrake  
www.github.com/ffmpeg/ffmpeg  
www.github.com/CCExtractor/ccextractor  
www.github.com/linuxserver/docker-baseimage-ubuntu  
www.github.com/jrottenberg/ffmpeg
