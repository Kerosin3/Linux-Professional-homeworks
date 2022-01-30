#/bin/bash
echo
#X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
#Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
#все ошибки c момента последнего запуска;
#echo "starting working at $now"
rflag=false
modeflag0=false
modeflag1=false
filemane=''

if [[ -s .log ]]; then #exists and not empty
  last_done=$(tail -n 1 .log)
  now="$(date +'%d/%b/%Y:%H:%M:%S %z')" # setting now if the script runs for the first time
  echo "last script run was at $last_done" # read timedone if it was once done
else # not existing
  touch .log #creating
  now="$(date +'%d/%b/%Y:%H:%M:%S %z')" # setting now if the script runs for the first time
  last_done=$now
fi

#------------------------------------------------------------------------------------------------#
# 1 param - filename, 
function get_resources_calls {
	start_analysis=1
	#all_resources_but=$(ack --output='$1' 'GET (/\S+?(?=\s))' | tail -n +$start_analysis )  # filter out all unnecessary
	all_resources_but=$(cat $1 | tail -n +$start_analysis | ack --output='$1' 'GET (/\S+?(?=\s))') # start fron start analysis_date and get all GET requests resources names
	all_resources_but_n=$(cat $1 | tail -n +$start_analysis | ack --output='$1' 'GET (/\S+?(?=\s))' | wc -l) # start fron start analysis_date and get all GET requests resources names

	#echo "dasdas $main_page_count"

	n_requests=$(cat $1 | tail -n +$start_analysis | ack --output='$1' 'GET /' | wc -l) # start fron start analysis_date and get all GET requests resources names including / page
	#n_requests=$((n_requests + main_page_count))  # add main page calls
	echo "total calls = $n_requests"
	echo "non root calls = $all_resources_but_n"
	unique_resources=$(echo "$all_resources_but" | sort --unique ) #  unique resources
	#echo "$(echo $unique_resources) | head -5"
	

	n_unique_resources=$(echo "$all_resources_but" | sort --unique | wc -l) #  n of unique resources
	#echo "$(echo $unique_resources) | head -5"
	declare -A resources_calls
	var_count_total=0
	iter0=0 
	for resource in $unique_resources # for each unique resource
	do
		count00=$(echo "$all_resources_but" |   grep  "$resource" | wc -l) # search n of coincedences ACK IS NOW WORKING HERE
		var_count_total=$((var_count_total + count00)) 
		echo "count is $count00, tc=$var_count_total resource is $resource"
		iter0=$((iter0 + 1)) 
		#echo "----------$iter0"
		#resource_calls["$resource"]="$count00" # assign
	#echo "value is $count"
    done
    echo "----------$var_count_total"
    main_page='/'
	main_page_count=0
	main_page_count=$(cat $1 | tail -n +$start_analysis | ack --output='$1' '(GET / )' | wc -l) #root calls
	if [ $main_page_count -ne 0 ] 
	then
		echo "main page count $main_page_count"
		var_count_total=$((var_count_total + main_page_count))
		#then unique_resources="${main_page}\n${unique_resources}" # add / to list of resources
	fi

	if [ $var_count_total -ne $n_requests ]
	then
		echo "some error while counting, aborting..... $var_count_total"
		exit 1
	fi
#
	#echo "$ip_iter was counted ${ip_calls["$ip_iter"]}"
	
#

}
#------------------------------------------------------------------------------------------------#
#1 param - filename, #2 - date last run
function search_time {
	declare -A time_calls
	#echo "$1"
	total_calls=$(wc -l < $1) # get n calls
	#echo $time_calls
	calls_time=$(ack --output='$1' '([[:digit:]][[:digit:]]\/.*?(?=\s\+0))' $1 | cut -d':' -f1-) # get data-time  $1 -problem..
#	echo $calls_time
	for call_n in $(seq 1 $total_calls);
	do
		time_this_call=$(echo "$calls_time" | sed -n "$call_n p") # get nth call time	
		time_calls["$call_n"]="$time_this_call" #filling array of times
	done
	now2=${now::-5} # removing timezone for now time
	#now2='14/Aug/2019:14:46:59' # test
	#now2='14/Aug/2019:14:54:00' # test
	
	last_call=${time_calls[$total_calls]} # last
	j=0
	start_analysis=1 # start from the very beginning
	for i in $(seq 1 $total_calls); #sequential 
	do
#	  echo "key  : $i"
  	  #echo "value : ${time_calls[$i]}"
	  if [[ ${time_calls[$i]} > ${now2} ]] # if current iteration date is greater than NOW2, then break and start from this date
	  	then 
			start_analysis=$i  # setting analysis start from
			break;
		#else  				
		#	j=$(expr $i - 1)
		#	start_analysis=$j
	  fi
	done
  echo  "analysis has started from n:$start_analysis, date: ${time_calls[$start_analysis]}"
  #echo ${time_calls[$start_analysis]}

}
#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
function calc_ip_calls {

uniq=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' $1  | tail -n +$start_analysis |cut -f 1 -d '-' | sort --unique )
nouniq_count=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' $1  | tail -n +$start_analysis |cut -f 1 -d '-' | wc -l)
nouniq_list=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' $1  | tail -n +$start_analysis |cut -f 1 -d '-' )
#echo 'strating counting'
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
#echo "total is $var_count_total"
#echo "estimated $nouniq_count"
if [ $var_count_total -ne $nouniq_count ]
then
	echo 'aborting'
	exit 1
fi
#("{ip_calls[*]}" | cut -f 1,4 -d ' ' | sort -k2,2 -nr)
#("{ip_calls[*]}" | cut -f 1,4 -d ' ')
echo "----------------------------------------------------"
echo "top acessed $count_n ip adressess:"
for x in "${!ip_calls[@]}"; do printf "[%s]=%s\n" "$x" "${ip_calls[$x]}" ; done | sort -k2,2 -t'=' -nr | head -$2
#echo 'ok, exiting....'
#exit 0!!!!!!!!!!!
}

#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
while getopts i:p:f: param;
do
	case "${param}" in
		i) echo "counting ips ${OPTARG}" 
			count_n="${OPTARG}"
			modeflag0=true
			;;
		p) echo "counter the most popular pages ${OPTARG}" 
			count_m="${OPTARG}"
			modeflag1=true
			;;
		f) echo "specified file to analysis ${OPTARG}" 
			rflag=true
			filename="${OPTARG}"
			;;

		*) echo "unknown flag $param" 
			;;
	esac
done
search_time "$filename"
#checking necessary flags
if ((OPTIND == 1))
then
    echo "No options specified"
fi

#shift $((OPTIND - 1))

if (($# == 0))
then
    echo "No positional arguments specified"
fi
if ! $rflag #&& [[ -d $1 ]]
then
    echo "file to analysis have to be specified, terminating..." >&2
    exit 1
fi
#------------------------------------------------------------------------------------------------#
#checking passed arguments
#------------------------------------------------------------------------------------------------#
if [ "$modeflag1" != true ] && [ "$modeflag0" != true  ]
then
	echo 'either i or p flag have to be specified, terminating'
	exit 1
else
	if [ "$modeflag0" = true  ] 
	then
		uniq_t=$(sed -n '/^[[:digit:]][[:digit:]][[:digit:]]*/p' $filename  |cut -f 1 -d '-' | sort --unique | wc -l ) #unique count
		if ! ([ "$count_n" -gt 0  ] && [ "$count_n" -le $uniq_t  ]) # if we counting smt greater 0 and lesser than max uniq ip in the file
		then
			echo 'specified value have to be greater that 0 and less or equal then uniq ip in the log, terminating...'
			exit 1
		fi

	fi

	if [ "$modeflag1" = true  ] 
	then
		if ! [ "$count_m" -gt 0  ]
		then
			echo 'specified value have to be greater that 0, terminating...'
			exit 1
		fi

	fi

fi
#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
if [ "$modeflag0" = true  ] # counting ips...
then
	calc_ip_calls "$filename" "$count_n"
fi

if [ "$modeflag1" = true  ] #counting pages
then
	#count_pages_requests "$filename" "$count_m"
	get_resources_calls "$filename"  #"$count_m"
fi


#------------------------------------------------------------------------------------------------#
if [ -w .log ] 
then
	echo "$now" >> .log # write this time script worked out
else
	echo 'cannot write to .log file'
	exit 1
fi
exit 0


#exit
######################main###################


#

