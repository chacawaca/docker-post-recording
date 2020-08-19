#!/usr/bin/with-contenv bash
if [ ${ENCODER} = "nvidia" ] ; then
ENCODER_SCRIPT=nvidia
fi
if [ ${ENCODER} = "intel" ] ; then
ENCODER_SCRIPT=intel
fi
if [ ${ENCODER} = "software" ] ; then
ENCODER_SCRIPT=software
fi
if [ ${ENCODER} = "custom" ] ; then
    if [ -f "/config/scripts/custom.sh" ] ; then
		echo "Custom script found"
        chmod +x /config/scripts/custom.sh
        sed -i "s|scripts/ENCODEREND|config/scripts/custom.sh|g" /etc/services.d/autovideoconverter/run
        sed -i "s|ENCODEREND|custom.sh|g" /etc/services.d/autovideoconverter/run
    else echo "ERROR: Please save the custom script to /config/scripts/custom.sh"
    fi
fi
if [ ${SUBTITLES} = "0" ] ; then
ENCODER_SCRIPT_END=.sh
else ENCODER_SCRIPT_END=-subtitles.sh
fi

if [ ! -f /bin/sh ]; then
    ln -s /usr/bin/dash /bin/sh && ln -s /usr/bin/bash /bin/bash
fi
chmod +x /scripts/*
sed -i "s/ENCODER/$ENCODER_SCRIPT/g" /etc/services.d/autovideoconverter/run
sed -i "s/END/$ENCODER_SCRIPT_END/g" /etc/services.d/autovideoconverter/run
sed -i "s/SEDUSER/$PUID/g" /etc/cont-init.d/10-autoconvertor.sh
sed -i "s/SEDGROUP/$PGID/g" /etc/cont-init.d/10-autoconvertor.sh
sed -i "s/SEDUSER/$PUID/g" /etc/services.d/autovideoconverter/run
sed -i "s/SEDGROUP/$PGID/g" /etc/services.d/autovideoconverter/run

