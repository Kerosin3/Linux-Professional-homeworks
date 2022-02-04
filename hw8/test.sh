#/bin/bash
now2_t='14:Aug:2019:10:30:58'
echo $now2_t
month=$(echo "$now2_t" | cut -f 2 -d ':')
echo $month
#-------------------------------------#
months=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
declare -A mlookup
for monthnum in ${!months[@]}
do
    mlookup[${months[monthnum]}]=$((monthnum + 1))
done

now=${mlookup["$month"]}
echo "=======$now"
echo $(echo $now2_t | sed "s/Aug/$now/g" )
#index=4
#echo "----------${now2_t:0:$index-1}$now${s:7}"
#echo "${mlookup["Jun"]}"    # outputs 6
