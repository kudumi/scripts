pushd /depot/phone/proj/main/scripts &>/dev/null # ensure in build directory

feedback=$(for phone in p2 p8 p8cg; do

    (./build-shoretel.sh $phone embedded release >&2 & \
	wait %1; code=$?; [ $code -ne 0 ] && echo $phone:$code ) &
done)

[ -z $feedback ] && exit 0	# exit gracefully without errors

echo "There were errors!"
exit 1
