#!/usr/bin/bash

#domain=$1
while read sub; do
	if host $sub &>/dev/null ; then
		echo " Checking $sub" #&>/dev/null
	else 
		if host -t CNAME $sub >/dev/null; then
			cname=$(host -t CNAME $sub.$domain >/dev/null | awk '{print $NF}' | sed 's/.$//g')
			if ! host $cname &>/dev/null; then
				echo "Possibly, $sub is vulnerable to takeover!" | tee -a takeoverResults
			fi
		fi
	fi 
done < $1
