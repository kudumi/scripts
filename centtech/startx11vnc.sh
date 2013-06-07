# This script enables the x11vnc server to persist until system reboot.

unset no_password password

while [[ $1 == *"-"* ]]; do
    case $1 in
	--no-passwd|-np ) no_password=1 ;;
	* ) echo "Unrecognized flag. Ignoring $1..."
    esac
    shift
done

[[ -z $no_password ]] && password="-rfbauth $HOME/.vnc/passwd"

x11vnc -forever -viewonly $password -display :0 &>/dev/null &
