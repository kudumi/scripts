# This code runs on the phone and completes the update

if [ -f /tmp/*_phone ]; then
    echo -n 'Deleting previous phone image...'
    rm /voip/*_phone
    echo 'done'

    echo -n 'Moving new image to forebrain...'
    mv /tmp/*_phone /voip/
    echo 'done'
    reboot

else
    echo 'The new firmware could not be found.'
    exit 1
fi
