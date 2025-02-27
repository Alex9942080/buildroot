#!/bin/sh

if [ ! -f $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY.lock ]; then
	echo "Script works on Wayland screen only!"
	exit 1
fi

for i in gst-inspect-1.0 gst-launch-1.0; do
	if ! which $i >/dev/null 2>&1; then
		echo "Script cannot be executed due missing \"$i\" tool!"
		exit 1
	fi
done

plugincheck()
{
	gst-inspect-1.0 --exists $1

	if [ $? -ne 0 ]; then
		echo "Script cannot be executed due missing \"$1\" plugin!"
		exit 1
	fi
}

plugincheck v4l2src
gst-inspect-1.0 --exists v4l2convert
if [ $? -eq 0 ]; then
	FMT="video/x-raw,width=1920,height=1080"
	PIPE="v4l2convert"
	echo "Using hardware format conversion"
else
	plugincheck glupload
	plugincheck glcolorconvert
	plugincheck gldownload
	FMT="video/x-raw,format=UYVY,width=1920,height=1080"
	PIPE="queue ! glupload ! glcolorconvert ! gldownload"
	echo "Using OpenGL format conversion"
fi

plugincheck waylandsink

gst-launch-1.0 \
v4l2src device=/dev/video0 ! \
$FMT ! \
$PIPE ! \
video/x-raw,format=RGB16 ! waylandsink

exit 0
