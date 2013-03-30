echo "GERTY-specific: Early 2009"
echo "Workstation Name: " `scutil --get ComputerName;`
echo "UserName: " `whoami`
echo "Memory: " `sw_vers | awk -F':t' '{print $2}' | paste -d ' ' - - -; 
sysctl -n hw.memsize | awk '{print $0/1073741824" GB RAM"}';` 
echo "Architecture: " `sysctl -n machdep.cpu.brand_string;` 
sw_vers
echo "LAN IP Address: " `ifconfig en0 | grep "inet" | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'`
echo "Wireless IP Address: " `ifconfig en1 | grep "inet" | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}'`
