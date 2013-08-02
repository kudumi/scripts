interface=`ip addr | grep -e "wlp[a-z0-9]*" | head -n1 | cut -d' ' -f2 | sed s/://g`
sudo wpa_supplicant -B -c/etc/wpa_supplicant.conf -Dnl80211 -i${interface}

# Wait for stability
while [[ -z `ps -e | grep wpa_supplicant` ]]; do
    sleep 1
done
sleep 1				# one more for good measure

sudo dhcpcd ${interface}
