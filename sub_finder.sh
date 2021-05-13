#!/bin/bash
target=$1

echo "#####################################"
echo "       First Level - Sub Enum       "
echo "#####################################"
#assetfinder
assetfinder --subs-only $target | grep -v '\*' | rev | cut -d. -f1-3 | rev | sort -u | tee 1st-$target-subs.txt
#subfinder
subfinder -d $target -silent | grep -v '\*' | rev | cut -d. -f1-3 | rev | sort -u | tee -a 1st-$target-subs.txt
#amass
amass enum -passive -d $target | grep -v '\*' | rev | cut -d. -f1-3 | rev | sort -u | tee -a 1st-$target-subs.txt
#Certificate Transparency
curl -sk "https://crt.sh/?q=%25.$1&output=json" | jq -r '.[]["common_name"]' | sed '/^*/d' | sort -u|tee -a 1st-$target-subs.txt





#sort
cat *.txt | sort -u | tee 1st-all-subs.txt
rm 1st-$target-*
####
echo "####################################"
echo "      Second Level - Sub Enum       "
echo "####################################"
cat 1st-all-subs.txt | xargs -P 100 -n 1 -I@ sh -c "assetfinder --subs-only '@' | grep -v '\*'| tee -a 2nd-subs.txt"
cat 1st-all-subs.txt | xargs -P 100 -n 1 -I@ sh -c "subfinder -d '@' -silent | grep -v '\*'| tee -a 2nd-subs.txt"
cat 1st-all-subs.txt 2nd-subs.txt | sort -u | tee all.txt
####
#sttus code
echo "#############################"
echo "       status-title         "
echo "#############################"
cat all.txt | httpx -silent -H "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36" -status-code -content-length -title | tee status-title.txt 
