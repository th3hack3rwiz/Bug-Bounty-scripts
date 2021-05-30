read -p "Enter cookies: " cookie
read -p "Enter url file: " url
for line in $(cat $url | gf lfi | qsreplace FUZZ) 
do echo "[+] running on $line" 
printf "\n" 
ffuf -u $line -replay-proxy http://127.0.0.1:8080 -b "$cookie" -H "User-Agent: KALI" -t 20 -p 1 -mc 200 -w ~/tools/SecLists/Fuzzing/lfi.txt ; done
