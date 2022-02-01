#/bin/bash
#echo
#X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
#Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
#все ошибки c момента последнего запуска;
#echo "starting working at $now"
rflag=false
eflag=false
modeflag0=false
modeflag1=false
filemane=''
#creating log file to precess date
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
	#ack version (getting rid of GET suffiix)
	all_resources_but=$(cat $1 | tail -n +$start_analysis | ack --output='$1' 'GET (/\S+?(?=\s))') # start fron start analysis_date and get all GET requests resources names
	#all_resources_but=$(cat $1 | tail -n +$start_analysis | grep -P 'GET /\S+?(?=\s)') # start fron start analysis_date and get all GET requests resources names
	all_resources_but_n=$(cat $1 | tail -n +$start_analysis | grep -P -c 'GET /\S+?(?=\s)') # n of get requests excluding / page
	n_requests=$(cat $1 | tail -n +$start_analysis | grep -c 'GET /' ) # start fron start analysis_date and get all GET requests resources names including / page
	unique_resources=$(echo "$all_resources_but" | sort --unique ) #  unique resources
	n_unique_resources=$(echo "$unique_resources" | wc -l) #  n of unique resources
	declare -A resources_calls
	var_count_total=0
	iter0=0 
	for resource in $unique_resources # for each unique resource
	do
		count00=0
		count00=$(echo "$all_resources_but" |   grep -P "${resource}( |$)" | wc -l ) # search n of coincedences ACK IS NOW WORKING HERE GREP iE P
		# GREP ONLY WORKING IN PERL MODE SOME MAGIC!!!
		if [ $count00 -eq 0  ]
		then
			count00=$(echo "$all_resources_but" |  grep  -c "$resource") # perl mode cannon deal with basic resources form, if 0 - count as usually.
		fi
		if [ $count00 -eq 0  ] #check second time, have not to be eq to zero!
		then
			echo "unknown error while pattern matching, aborting..."
			exit 1
		fi
		var_count_total=$((var_count_total + count00)) 
		resource_calls["$count00"]="$resource" # assign
    done
    main_page='/'
	main_page_count=0
	main_page_count=$(cat $1 | tail -n +$start_analysis | ack --output='$1' '(GET / )' | wc -l) #root calls
	if [ $main_page_count -ne 0 ] 
	then
		var_count_total=$((var_count_total + main_page_count))
		resource_calls["$main_page_count"]="/"
	fi

	if [ $var_count_total -ne $n_requests ] #check if total counted resoucess call eq to n of call GET
	then
		echo "some error while counting, aborting..... $var_count_total != $n_requests"
		exit 1
	else
		echo "ok"
	fi
#	for n_calls in "${!resource_calls[@]}"; do
#  		echo " n calls:$n_calls, resource -> ${resource_calls[$n_calls]}"
#	done
	echo "----------------------------------------------------"
	echo "$count_m top requested pages"
	for x in "${!resource_calls[@]}"; do printf "page [%s] %s times\n" "${resource_calls[$x]}" "$x"; done  | tail -$count_m | tac | column -t
}
#------------------------------------------------------------------------------------------------#
#1 param - filename, #2 - date last run
function search_time {
	declare -A time_calls
	total_calls=$(wc -l < $1) # get n calls
	calls_time=$(ack --output='$1' '([[:digit:]][[:digit:]]\/.*?(?=\s\+0))' $1 | cut -d':' -f1-) # get data-time  $1 -problem..
	for call_n in $(seq 1 $total_calls);
	do
		time_this_call=$(echo "$calls_time" | sed -n "$call_n p") # get nth call time	
		time_calls["$call_n"]="$time_this_call" #filling array of times
	done
	now2=${now::-5} # removing timezone for now time
	last_call=${time_calls[$total_calls]} # last
	j=0
	start_analysis=1 # start from the very beginning
	for i in $(seq 1 $total_calls); #sequential 
	do
	  if [[ ${time_calls[$i]} > ${now2} ]] # if current iteration date is greater than NOW2, then break and start from this date
	  	then 
			start_analysis=$i  # setting analysis start from
			break;
	  fi
	done
  echo  "analysis has started from n:$start_analysis, date: ${time_calls[$start_analysis]}"

}
#------------------------------------------------------------------------------------------------#
# search time for erros
function print_error {
#	filenameE='error_log'
	if [ -f $filenameE ] 
	then
		dates_errors=$(cat $filenameE) #| tail -n +start_analysis) # cut
		dates_errors_n=$(cat $filenameE | wc -l) #| tail -n +start_analysis) # cut
		if [ $dates_errors_n -eq 0 ] 
			then
				echo "there is nothing in error log file, skipping"
		fi
		current_date_errors="$(date +'%d/%m/%Y %H:%M:%S')"
		line_date_analysis=1
		for i in $(seq 1 $dates_errors_n)
		do
			i_line=$(echo "$dates_errors" | sed -n "$i p"| cut -f 1,2 -d ' ') # take i line and take date and time
			#i_line=$(echo "$dates_time" | tail  -n +$i) # take i line
			#i_line=$(echo "$dates_time" | awk "NR == n1" n1=$i) # take i line
			#i_line_date=$(echo $i_line | cut -f 1,2 -d ' ') # take date
			if [[ ${current_date_errors} > ${i_line} ]] #once we are later, take previous
				then 	
	     				if [ $i -eq 1  ]	
					then
					       break # line = 1
					else
						line_date_analysis=$[$i_line - 1] # take previous
						break
					fi
			fi
		done
		echo "----------------------------------------------------"
		echo "analysing error file from $line_date_analysis'st line"
		echo "----------------------------------------------------"
		out0=$(echo "$dates_errors" | tail -n +$line_date_analysis  | cut -f 1,2,4 -d ' ' | column -t -N date,time,error_code) # take i line and take date and time
		echo "$out0"
	else
		echo 'error file now found, skipping error analysing'
	fi
#	14/Aug/2019:04:12:10
}
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
done
if [ $var_count_total -ne $nouniq_count ]
then
	echo 'aborting'
	exit 1
fi
echo "----------------------------------------------------"
echo "$count_n top acessed ip adressess:"
for x in "${!ip_calls[@]}"; do printf "ip-address [%s] %s times\n" "$x" "${ip_calls[$x]}" ; done | sort -k3 -t' ' -nr | head -$2 | column -t
}

#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------#
while getopts i:p:f:e: param;
do
	case "${param}" in
		i) echo "counting ip that acessed the server ${OPTARG}" 
			count_n="${OPTARG}"
			modeflag0=true
			;;
		p) echo "counting the most popular pages ${OPTARG}" 
			count_m="${OPTARG}"
			modeflag1=true
			;;
		f) echo "specified file to analysis ${OPTARG}" 
			rflag=true
			filename="${OPTARG}"
			;;
		e) echo "specified error file to analysis ${OPTARG}" 
			eflag=true
			filenameE="${OPTARG}"
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
if ! $rflag  || ! $eflag #&& [[ -d $1 ]]
then
    echo "file to analysis and error file have to be specified, terminating..." >&2
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
		all_resources_but_n_uniq=$(cat $filename | tail -n +$start_analysis | ack --output='$1' 'GET (/\S+?(?=\s))'| sort --unique | wc -l) # start fron start analysis_date and get all GET requests resources names
		if ! [ "$count_m" -gt 0  ]
		then
			echo 'specified value have to be greater that 0, terminating...'
			exit 1
		fi
		if [ "$count_m" -gt "$all_resources_but_n_uniq" ]
		then
			echo "unique resources n: $all_resources_but_n_uniq"
			echo 'entered number of resources have to be less than n of uniq resources in log file, aborting..'	
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
print_error
exit 0


#exit
######################main###################


#

