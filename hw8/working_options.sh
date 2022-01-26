#/bin/bash

#echo 
while [ -n "$1" ]
do
	case "$1" in 
		-a) echo "a option" ;;
		-b) echo "b option" ;;
	esac
	shift
done
#echo
exit
