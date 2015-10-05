#!/bin/sh
# done by seikath
# 2015-10-05

# check executable permissions
echo "$(date) : checking if the ${0} is executable} .. "
test ! -x ${0} && echo "$(date) : ${0} is non executable. Please chmod +x it and try again" && exit 0 
echo "$(date) : the ${0} is executable} .. "

# loading the slow log filename as argument 
test -z ${@} & echo "$(date) : loading the slow log as an argument failed, please  use the scritp as ${0} full_file_name!"
_slow_log=${1}

# disabled for the v2.x
# include the user / host / password for future usage with pt-index-usage
##################################################################################################################################################
###
### echo "$(date) : checking the ${0%.*}.conf .."
### test ! -f ${0%.*}.conf && echo "$(date) : the config file ${0%.*}.conf file is missing, exiting noe" && exit 0
### echo "$(date) : loading the ${0%.*}.conf .."
### source ${0%.*}.conf
### test $?0 -gt 0 && echo "$(date) : config file failed to load" && exit 0
### test -z $_user && echo "$(date) : loading the ${0%.*}.conf loaded but there is missing _user value. cannot continue, exiting" && exit 0
### 
##################################################################################################################################################

# better solution as we might execute it any day beore the next friday .. 
get_start_friday_unix_timestamp=$(date -d "last friday" +%s)
get_end_friday_unix_timestamp=$(date -d "last saturday" +%s)

slow_log=${_slow_log}
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
${slow_log} > ${slow_log}.last.friday
test $? -gt 0 && echo "$(date) : ERROR getting the mysql slow data for the last Friday .. exiting now !" && exit 0
echo "$(date) : finalized extracing the last Friday part of the mysql slow log ..."
echo "$(date) : proceeding with the index usage analisis with pt-index-usage .. to be done in other script to be included"


