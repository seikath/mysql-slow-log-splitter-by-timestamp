#!/bin/sh
# done for Altima by seikath
# start 2015-10-02

# 1   : crontab to activate the global userstat at 00:00 every friday
# 0 0 * * 5  mysql -e 'use information_schema; flush INDEX_STATISTICS; set global userstat=1;' && echo "$(date) : $HOSTNAME MariaDB userstat has been enabled" >> /var/log/$HOSTNAME.mariadb.dynamic.config.changes.log 2>&1
# 1.1 : optional - flush the INDEX_STATISTICS table or not - make it configurable ...  bash script to be executed instead of the command lines 

# 2   : cron job to disable the global userstat at 00:00 every saturday  
# 0 0 * * 6  mysql -e 'set global userstat=0;' && echo "$(date) : $HOSTNAME MariaDB userstat has been disabled" >> /var/log/$HOSTNAME.mariadb.dynamic.config.changes.log 2>&1

# 3   : get the /tmp/mysql-slow.log part for  Friday DONE : 

# 3.1   : execute the pt-index-usage using that part to generate the report , check for the approproate time to do that in a view to avoid loading the production server
#


# check executable permissions

echo "$(date) : checking if the ${0} is executable} .. "
test ! -x ${0} && echo "$(date) : ${0} is non executable. Please chmod +x it and try again" && exit 0 
echo "$(date) : the ${0} is executable} .. "

# include the user / host / password 
test -f ${0%.*}.conf && source ${0%.*}.conf && test ! -z $_user && echo "$(date) : config file loaded"

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



