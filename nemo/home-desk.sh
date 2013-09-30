#!/bin/bash

source $HOME/Dropbox/config/bash/bash.error.sh

case $1 in

    ""|-h|--help)
	cat<<EOF
`basename $0`: A script to display two monitors from the ThinkPad dock.

Possible arguments are as follows

         --help
         -h       Display this help information. `basename $0` has no man page.

         --normal
         -n       Normal display (LDVS only)

     Screen activation:
        --right
	-r        Activate the right external monitor.

        --left
	-l        Activate the left external monitor.

     Screen rotation:
         --rotate-right
         -rr      Rotate the right screen (to the left).
                  This will activate the right screen.

         --rotate-left
         -rl      Rotate the left screen (to the left).
                  This will activate the left screen.
EOF
	exit $EXIT_HELP
	;;
esac

# Without the user specifying a screen should be 'on',
# all screens start in the 'off' position.
hdmi3="--output HDMI3 --off"
hdmi2="--output HDMI2 --off"

while [[ $1 ]]; do
    case $1 in

	-l|--left)
	    hdmi3="--output HDMI3 --auto"
	    hdmi3_orientation="--rotate normal"
	    ;;

	-r|--right)
	    hdmi2="--output HDMI2 --auto --right-of HDMI3"
	    hdmi2_orientation="--rotate normal"
	    ;;

	-rl|--rotate-left)
	    hdmi3="--output HDMI3 --auto"
	    hdmi3_orientation="--rotate left"
	    ;;

	-rr|--rotate-right)
	    hdmi2="--output HDMI2 --auto --right-of HDMI3"
	    hdmi2_orientation="--rotate left"
	    ;;

	-n|--normal)
	    ;;

    esac
    shift
done

xrandr ${hdmi3} ${hdmi3_orientation} ${hdmi2} ${hdmi2_orientation}
