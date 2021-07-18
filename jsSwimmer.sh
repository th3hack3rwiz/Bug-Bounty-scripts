#!/bin/bash
domain=$1
file=$2

function jsReconStart(){
count=0
jsfiles=$(cat $1 | wc -l)
echo -e  "${GREEN}[+] Starting LinkFinder to find JS links and SecretFinder to find some secrets... "
printf "\n" 
while read line ; do
url=$(echo $line | sed "s#$domain.*#$domain\/#g")
echo -e "${GREEN}[+] Running on $line " >> $domain.linkFinderOutput.txt
echo -ne "[+] Finding endpoints on $line\n\tTotal potential endpoints found: $count\t JS Files remaining: $jsfiles \\r" #fetching base URL
jsfiles=$(($jsfiles - 1))
python3 ~/tools/secretfinder/SecretFinder.py -i $line -o cli >> $domain.JSecret
printf "\n"  >> $domain.linkFinderOutput.txt
python3 ~/tools/LinkFinder/linkfinder.py -o cli -i $line > temp 2>&1  #storing endpoints
cat temp | grep -E "SSL error|DH_KEY_TOO_SMALL" >/dev/null
if [ $? -eq 0 ]; then
echo "">temp
else 
cat temp >> $domain.linkFinderOutput.txt
for j in $(cat temp | grep -vE "^/$|%|\-\-|[[:lower:]]+-[[:lower:]]+-[[:lower:]]+|^[[:digit:]]+|^-|^_|^-[[:digit:]]|^[[:lower:]]+[[:upper:]]|.*,.*|[[:upper:]]+[[:lower:]]+[[:upper:]]+|_|[[:upper:]]+[[:digit:]]+|[[:lower:]]+[[:digit:]][[:digit:]]+[[:lower:]]*|[[:upper:]]+[[:digit:]][[:digit:]]+[[:lower:]]*|[[:alpha:]]+-[[:alpha:]]+-|@|^[[:digit:]]+|\.html$|==$|\.png$|\.jpg$|\.css$|\.gif$|\.pdf$|\.jpeg$|\.png$|\.tif$|\.tiff$|\.ttf$|\.woff$|\.woff2$|\.ico$|\.svg$") ; do
echo $j |xargs --max-args=1 --replace="{}" echo "$url{}" 2>&1 | grep $domain | sed "s#$domain\/*#$domain\/#g" | anew jsEndpointsx | wc -l >add
count=$(($count + $(cat add)))
rm add
done
rm temp
fi
done < $1
ffuf -s -u FUZZ -w jsEndpointsx -t 200 -mc 200,301,302,403 -sa -fs 0 -fr "Not Found" -of csv -o testx | tee endpoints
rm jsEndpointsx
cat endpoints | grep -E ".js$" | sed 's/.*http/http/g' | fff > freshJs
rm endpoints
cat freshJs | grep -E "200$" | tr -d '200' | xargs -n1 | anew $file | tee newJs
#ffuf -s -u FUZZ -w jsEndpointsx -t 200 -mc 200,301,302,403 -sa -fs 0 -fr "Not Found" -of csv -o testx 
cat testx | sed s/'^.*http'/http/g | sed 's/\,\,/ /g' | qsreplace -a | sed 's/%20/ /g' | sed 's/ [[:digit:]]*,/                    /g' | sed 's/,$//g' | grep http | sort -u | sed 's/.*http/http/g' | anew -q jsActiveEndpoints 2>&1 ; rm testx
#cat jsActiveEndpoints | grep -E "\.js" | grep 200, | sed 's/200,.*//g' |xargs -n1 |  grep -E '\.js$' #JS files extracted
#cat jsActiveEndpoints | grep -E "\.js" | grep 200, | sed 's/200,.*//g' |xargs -n1 |  grep -E '\.js$' | anew $file 


if [ ! -s newJs ]; then echo "[-] No new JS files found!" ; rm newJs ; 
else
echo "$(cat newJs | wc -l)New JS Files found!" | notify
jsReconStart "newJs"
fi 
}
jsReconStart "$file"
rm freshJs
