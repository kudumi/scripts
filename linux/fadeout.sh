while [ `volume` -gt 0 ]; do
    vol=`volume`
    sleep=`echo 48 - 60/$vol | bc`
    sleep $sleep
    volume -1
done
