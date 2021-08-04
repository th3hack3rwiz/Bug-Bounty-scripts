airmon-ng stop wlan0mon >/dev/null 2>&1
airmon-ng check kill
ifconfig wlan0 down
ifconfig wlan0 up
sleep 2
rfkill unblock all
airmon-ng start wlan0
rfkill unblock wifi
airodump-ng wlan0mon
