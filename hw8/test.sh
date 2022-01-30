#/bin/bash
export TEST='15/Aug/2019:00:24:38 +0300'
export TEST2='15/Aug/2019:00:22:38 +0300'
if [[ $TEST < $TEST2 ]] # if current iteration date is greater than NOW, then break and start from this date
	  	then
			echo 'OKKKKKKKKKKKK'  #
	#		break;
		else
			echo 'NO OKKKKKKKKKKKKKK'
		#else
		#	j=$(expr $i - 1)
		#	start_analysis=$j
	  fi
