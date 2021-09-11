#!/bin/bash
user=$(whoami)
cat ${1}.ipList.txt | grep -oE "([0-9]{1,3}[\.]){3}[0-9]{1,3}" > buff ; cat buff > ${1}.ipList.txt ; rm buff
echo -e "[+] Starting masscan..."
sudo masscan -iL ${1}.ipList.txt -p0-65535 --rate=10000 -oL scan.txt
sudo chown $user:$user scan.txt
cat scan.txt | awk '{print $3,$4}' | sed '/^[[:space:]]*$/d' >> port_ip 
rm scan.txt
for i in $(cat port_ip | awk '{print $2}' | grep -o -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |sort -u); do ports=$(cat port_ip | grep $i | awk '{print $1}' | sort -u | xargs | sed 's/[[:space:]]/,/g') ; echo "$i $ports" | anew -q nmapme; done
file=nmapme
while read i
 do
  port=$(echo $i | awk '{print $2}')
  ip=$(echo $i | awk '{print $1}')
  #echo $port $ip
  sudo nmap -sV -Pn -A -p $port $ip -sC -T4 --script vulners.nse,vulscan/vulscan.nse | tee -a nmap_results
done < $file 
rm nmapme
