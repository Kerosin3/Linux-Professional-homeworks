#/bin/bash
echo
rflag=false
modeflag0=false
modeflag1=false
filemane=''
function test {
	echo "parameter #1 is $1"
}
function calc_ip_calls {

uniq=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' $1  |cut -f 1 -d '-' | sort --unique )
nouniq_count=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' $1  |cut -f 1 -d '-' | wc -l)
nouniq_list=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' $1  |cut -f 1 -d '-' )
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
for x in "${!ip_calls[@]}"; do printf "[%s]=%s\n" "$x" "${ip_calls[$x]}" ; done | sort -k2,2 -t'=' -nr | head -$2
echo 'ok, exiting....'
exit 0
}

while getopts a:b:f: param;
do
	case "${param}" in
		a) echo "found some 1 flag with value ${OPTARG}" 
			count_n="${OPTARG}"
			modeflag0=true
			echo "value is $count"
			;;
		b) echo "found some 2 flag ${OPTARG}" 
			count_n="${OPTARG}"
			modeflag1=true
			;;
		f) echo "analysing file with name ${OPTARG}" 
			rflag=true
			filename="${OPTARG}"
			;;

		*) echo "unknown flag $param" 
			;;
	esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
fi

#shift $((OPTIND - 1))

if (($# == 0))
then
    echo "No positional arguments specified"
fi

#test "asdasd"
calc_ip_calls "$filename" "$count_n"
if ! $rflag #&& [[ -d $1 ]]
then
    echo "file to analysis have to be specified, terminating..." >&2
    exit 1
fi
exit
######################main###################


#

