#echo -e "`date | awk '{print $1,$2,$3,$4}'` - Download completed\n$1" | ssmtp $email
echo "$(date) : $1 - Download completed." | mail -s "[rtorrent] - Download completed : $1" eric.s.crosson@gmail.com
