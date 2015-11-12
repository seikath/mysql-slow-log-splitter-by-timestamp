#!/bin/sh
# done for Altima by seikath
# start 2015-10-02
# 10 0 * * * /root/bin/make.daily.extract.from.mysql.slow.log.sh PATH_HERE DB_CHEMA >> /var/log/make.daily.extract.from.mysql.slow.log.log 2>&1

# import local config if its working on my Mac
# make the life easier at my Mac 1
test "$(hostname)" == "darkwastar.on.mac" \
&& test -f bash.config.conf \
&& test -r bash.config.conf \
&& source bash.config.conf

# here a dialog to get the start and end time stamps 
get_start_unix_timestamp=$(date -d "1 day ago 00" +%s) # here again should be argument driven
get_end_unix_timestamp=$(date +%s) # here again should be argument driven - or not, as this NOW in fact

# get the slow log location from the config
hash my_print_defaults 2>/dev/null \
&& configured_slow_log=$(my_print_defaults /etc/my.cnf mysqld | grep -i slow | sed '/slow[-_]query[-_]log[-_]file/!d;s/^.*=//')

test ! -z $configured_slow_log \
&& test -f $configured_slow_log \
&& test -r $configured_slow_log \
&& echo "$(date) : FYI we detected configured slow log here: ${configured_slow_log}"

# check arguments 
test ${#@} -eq 0 && echo "$(date) : usage : $(basename ${0}) mysql-slow.log_absolute_path dbname /case sensitive/" && exit 0

# slow log test, might be added a check if its real slow log before to start the extract  :
slow_log="${1}" 

# make the life easier at my Mac 2 
test "$(hostname)" == "darkwastar.on.mac" \
&& test -f bash.config.conf \
&& test -r bash.config.conf \
&& slow_log_default="${projects_proceed_slow_logs_directory}/${1}" \
&& test -f "${slow_log_default}" && test -r "${slow_log_default}" && slow_log="${slow_log_default}"

# check the file is readable 
test ! -f "${slow_log}"  \
&& echo "$(date) : the slow log ${slow_log} is non existing" \
&& echo "$(date) : FYI we detected configured slow log here: ${configured_slow_log}" \
&& exit 0  

echo "$(date) : proceeding with the ${slow_log} slow log ..."

# set some variables depending the provided schema name 
test ! -z ${2} \
&& schema="${2}" \
&& var_schema="-vschema=${schema}" \
&& echo "$(date) : checking for Schema: ${schema}" \
&& extract_file_schema="for.db.${schema}." \
|| (var_schema="" && extract_file_schema="")

# set the export name
compressed_extract_file_name=$(dirname ${slow_log})/$(hostname).$(basename ${slow_log}).${extract_file_schema}between.$(date -d @$get_start_unix_timestamp "+%Y-%m-%d.%H.%M.%S").and.$(date -d @$get_end_unix_timestamp "+%Y-%m-%d.%H.%M.%S").gz

awk ${var_schema} -vget_start_unix_timestamp=$get_start_unix_timestamp -vget_end_unix_timestamp=$get_end_unix_timestamp '
BEGIN{
printit=0;
}
{ if ($0 ~ /^SET timestamp=/)
    {
       timestamp=$2; \
       sub(/;$/,"",timestamp); \
       sub(/^.*=/,"",timestamp); \
       #print "timestamp=>"timestamp;
       if (timestamp>=get_start_unix_timestamp && timestamp<=get_end_unix_timestamp) {printit=1;} else {printit=0;} 
    } 
    # added filtering per schema
    if (schema!="") {
		if ($0 ~ /^\# Time:/)
		{
			time_line=$0; \
			next
		} 
		if ($0 ~ /^\# User@Host:/)
		{
			user_line=$0; \
			next
		}
		if ($0 ~ /^\# Thread_id:/ && $5==schema) 
		{
			schema_print=1;
		} else if ($0 ~ /^\# Thread_id:/ && $5!=schema) {
			schema_print=0;
		}
		if ($0 ~ /^\# Thread_id:/ && schema_print==1 && printit==1)
		{
			print time_line; \
			print user_line;
		}    
		if (printit==1 && schema_print==1) { print$0 } 
    } else {
        if (printit==1) { print $0 }
    }
}' \
${slow_log} \
| gzip > ${compressed_extract_file_name}
test $? -gt 0 && echo "$(date) : ERROR getting the mysql slow data for that period .. exiting now !" && exit 0
echo "$(date) : finalized extracing the mysql slow log between $(date -d @$get_start_unix_timestamp +%Y-%m-%d.%H.%M.%S) and $(date -d @$get_end_unix_timestamp +%Y-%m-%d.%H.%M.%S)"
echo "$(date) : the extact is here : ${compressed_extract_file_name}"




