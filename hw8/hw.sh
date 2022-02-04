#/bin/bash
aa=15


function append_zeros {
	length_0=$(echo -n $1 | wc -m)
	if [ "$length_0" == '1' ]
	then
		echo "=============="
		v1=0$1
		echo $v1
		#$1="$v1"
	else
		echo $1
	fi
}

append_zeros $aa
