#!/bin/sh
# done by seikath

# check executable permissions

echo "$(date) : checking if the ${0} is executable} .. "
test ! -x ${0} && echo "$(date) : ${0} is non executable. Please chmod +x it and try again" && exit 0 
echo "$(date) : the ${0} is executable} .. "

# include the user / host / password 
echo "$(date) : checking the ${0%.*}.conf .."
test ! -f ${0%.*}.conf && echo "$(date) : the config file ${0%.*}.conf file is missing, exiting noe" && exit 0
echo "$(date) : loading the ${0%.*}.conf .."
source ${0%.*}.conf
test $?0 -gt 0 && echo "$(date) : config file failed to load" && exit 0
test -z $_user && echo "$(date) : loading the ${0%.*}.conf loaded but there is missing _user value. cannot continue, exiting" && exit 0

exit 0
# get_start_unix_timestamp=$(date -d "yesterday 00:00" +%s)
# get_start_unix_timestamp=$(date -d "today 00:00" +%s)

# better solotion as we might execute it any day beore the next friday .. 
get_start_friday_unix_timestamp=$(date -d "last friday" +%s)
get_end_friday_unix_timestamp=$(date -d "last saturday" +%s)


# local test :
slow_log=babami-slow.log
slow_log=${$_slow_log}
# check the file is readable 
test ! -f ${slow_log} && echo "the slow log ${slow_log} is non existing" && exit 0 
echo "$(date) : proceeding with the yesterday part of the slow log ..."

awk -vget_start_friday_unix_timestamp=$(date -d "last friday" +%s) -vget_end_friday_unix_timestamp=$(date -d "last saturday" +%s) '
BEGIN{
printit=0;
}
{ if ($0 ~ /^SET timestamp=/)
    {
       timestamp=$2; \
       sub(/;$/,"",timestamp); \
       sub(/^.*=/,"",timestamp); \
       #print "timestamp=>"timestamp;
       if (timestamp>=get_start_friday_unix_timestamp && timestamp<=get_end_friday_unix_timestamp) {printit=1;} else {printit=0;} 
    } 
    if (printit==1) { print $0 }
}' \
${slow_log} > ${slow_log}.last.friday.1
test $? -gt 0 && echo "$(date) : ERROR getting the mysql slow data for the last Friday .. exiting now !" && exit 0
echo "$(date) : finalized extracing the yesterday part of the mysql slow log ..."
echo "$(date) : proceeding with the index usage analisis .."



