#!/bin/bash

case $1 in

    r|ir|right)
	xrandr --output HDMI3 --auto --output HDMI2 --auto --right-of HDMI3 --rotate left
	;;
    l|il|left)
	xrandr --output HDMI3 --auto --rotate left --output HDMI2 --auto --right-of HDMI3
	;;
    ""|*)
	xrandr --output HDMI3 --auto --output HDMI2 --auto --right-of HDMI3
	;;
esac
