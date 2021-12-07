#/bin/bash
uniq=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' access-4560-644067.log  |cut -f 1 -d '-' | sort --unique )
nouniq_count=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' access-4560-644067.log  |cut -f 1 -d '-' | wc -l)
nouniq_list=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' access-4560-644067.log  |cut -f 1 -d '-' )
echo 'strating counting'
var_count_total=0
declare -A ip_calls
for ip_iter in $uniq
do
	count=$(echo "$nouniq_list" |  sed -n "/$ip_iter/p" | wc -l)
	var_count_total=$((var_count_total + count))
	ip_calls["$ip_iter"]="$count"
	#echo "value is $count"
	#echo "$ip_iter was counted ${ip_calls["$ip_iter"]}"
done
echo "total is $var_count_total"
echo "estimated $nouniq_count"
if [ $var_count_total -ne $nouniq_count ]
then
	echo 'aborting'
	exit 1
fi
#("{ip_calls[*]}" | cut -f 1,4 -d ' ' | sort -k2,2 -nr)
#("{ip_calls[*]}" | cut -f 1,4 -d ' ')
echo 'ip adress access list:'
for x in "${!ip_calls[@]}"; do printf "[%s]=%s\n" "$x" "${ip_calls[$x]}" ; done | sort -k2,2 -t'=' -nr
echo 'ok, exiting....'
exit 0
