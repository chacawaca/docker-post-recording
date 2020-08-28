#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.
USER_ID=SEDUSER
GROUP_ID=SEDGROUP

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Generate machine id.
if [ ! -f /etc/machine-id ]; then
    log "generating machine-id..."
    cat /proc/sys/kernel/random/uuid | tr -d '-' > /etc/machine-id
fi

# Make sure mandatory directories exist.
mkdir -p /config/ghb
mkdir -p /config/hooks
mkdir -p /config/log/ffmpeg
mkdir -p /config/log/ccextractor
mkdir -p /config/comskip
mkdir -p /config/scripts

# Copy default configuration if needed.
if [ ! -f /config/ghb/preferences.json ]; then
  cp /defaults/preferences.json /config/ghb/preferences.json
fi

# Copy example hooks if needed.
for hook in pre_conversion.sh post_conversion.sh post_watch_folder_processing.sh
do
  [ ! -f /config/hooks/$hook ] || continue
  [ ! -f /config/hooks/$hook.example ] || continue
  cp /defaults/hooks/$hook.example /config/hooks/
done

# Copy example scripts if needed.
for script in intel.sh nvidia.sh software.sh nvidia-hq.sh
do
  [ ! -f /config/scripts/$script ] || continue
  [ ! -f /config/scripts/$script.example ] || continue
  cp /defaults/scripts/$script.example /config/scripts/
done

#Copy default comskip.ini
if [ ! -f /config/comskip/comskip.ini ]; then
  cp /defaults/comskip/comskip.ini /config/comskip/comskip.ini
fi

# Copy custom.sh script if needed.
if [ ! -f /config/scripts/custom.sh ]; then
  cp /defaults/scripts/custom.sh /config/scripts/custom.sh
fi

# Make sure the debug log is under the proper directory.
[ ! -f /config/handbrake.debug.log ] || mv /config/handbrake.debug.log /config/log/hb/handbrake.debug.log

# Clear the fstab file to make sure its content is not displayed in HandBrake
# when opening the source video.
echo > /etc/fstab

# Print the core dump info.
log "core dump file location: $(cat /proc/sys/kernel/core_pattern)"
log "core dump file size: $(ulimit -a | grep "core file size" | awk '{print $NF}') (blocks)"

# Take ownership of the config directory content.
find /config -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;

# Take ownership of the output directory.
for i in $(seq 1 ${AUTOMATED_CONVERSION_MAX_WATCH_FOLDERS:-5}); do
    eval "DIR=\"\${AUTOMATED_CONVERSION_OUTPUT_DIR_$i:-/output}\""

    if [ ! -d "$DIR" ]; then
        log "ERROR: Output folder '$DIR' doesn't exist."
        exit 1
    elif ! chown $USER_ID:$GROUP_ID "$DIR"; then
        # Failed to take ownership of /output.  This could happen when,
        # for example, the folder is mapped to a network share.
        # Continue if we have write permission, else fail.
        if s6-setuidgid $USER_ID:$GROUP_ID [ ! -w "$DIR" ]; then
            log "ERROR: Failed to take ownership and no write permission on '$DIR'."
            exit 1
        fi
    fi
done

# vim: set ft=sh :
