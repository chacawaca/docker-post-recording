# docker-post-recording

Documentation is a WORK IN PROGRESS

Watches for .ts files made by Live TV recordings, convert them to a friendly format, extract .srt file, add chapters with comchap or remove them with comcut.
Tested with Emby recordings.

Example run

```shell
docker run -d \
	--name=post-recording \
	-v /docker/appdata/post-recording:/config:rw \
	-v /home/user/videos:/watch:rw \
	-e DELETE_TS=1 \
	-e CONVERSION_FORMAT=mkv \
	-e SOURCE_EXT=ts \
	-e POST_PROCESS=comchap \
	-e PUID=99 \
    	-e PGID=100 \
	-e UMASK=000 \
	--restart always \
	chacawaca/post-recording
```

Where:

- `/docker/appdata/recordings-converter`: This is where the application stores its configuration, log and any files needing persistency. 
- `/home/user/videos`: This location contains .ts files that need converting. Other files are not processed.  
- `DELETE_TS`: After converting remove the original .ts recording file. 1 = no, 0 = yes. **USE DELETE_TS=1 UNTIL YOU'RE SURE IT WORKS WITH YOUR VIDEO RECORDINGS.**
- `CONVERSION_FORMAT`: Select output extension, your custom.sh need to be valid for this extension.
- `SOURCE_EXT`: If you want to convert something else than .ts
- `POST_PROCESS`: option are comchap or comcut. default: comchap
- `PUID`: ID of the user the application runs as.
- `PGID`: ID of the group the application runs as.
- `UMASK`: Mask that controls how file permissions are set for newly created files.

Configuration: 

- /appdata/post-recording/scripts/custom.sh need to be configured for your need, some example are there to help you configure this for your need.
- /appdata/post-recording/hooks can be configured to execute custom code


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
copy your GPU UUID to NVIDIA_VISIBLE_DEVICES.  (-e NVIDIA_VISIBLE_DEVICES=GPU-XXXXXXXXXXXXXX)

## projects used

www.github.com/djaydev/docker-recordings-transcoder  
www.github.com/BrettSheleski/comchap  
www.github.com/erikkaashoek/Comskip  
www.github.com/jlesage/docker-handbrake  
www.github.com/ffmpeg/ffmpeg  
www.github.com/CCExtractor/ccextractor  
www.github.com/linuxserver/docker-baseimage-ubuntu  
www.github.com/jrottenberg/ffmpeg
