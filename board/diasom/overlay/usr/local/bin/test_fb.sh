#!/bin/sh

for i in gst-inspect-1.0 gst-launch-1.0; do
	if ! which $i >/dev/null 2>&1; then
		echo "Script cannot be executed due missing \"$i\" tool!"
		exit 1
	fi
done

plugincheck()
{
	gst-inspect-1.0 --exists $1
	if [[ $? -ne 0 ]]; then
		echo "Script cannot be executed due missing \"$1\" plugin!"
		exit 1
	fi
}

if [ -f $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY.lock ]; then
	OUTSINK=waylandsink
	echo "Wayland is active. Image will be dispalyed on the wayland screen!"
else
	OUTSINK=fbdevsink
	if [ ! -d /sys/class/graphics/fb0 ]; then
		echo "Script cannot be used without framebuffer!"
		exit 1
	fi
fi

plugincheck videotestsrc
plugincheck videoconvert
plugincheck $OUTSINK

# Switch between LVDS and HDMI output
if [ -d /sys/class/drm/card0-LVDS-1 ]; then
	FMT="video/x-raw,width=1024,height=768"
else
	FMT="video/x-raw,width=1920,height=1080"
fi

gst-launch-1.0 \
videotestsrc ! \
$FMT ! \
videoconvert ! \
$OUTSINK

exit 0
