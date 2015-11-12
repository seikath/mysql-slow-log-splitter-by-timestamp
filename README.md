# mysql-slow-log-splitter-by-timestamp
Extracts the part of the MariaDB, Percona or MySQL slow log between two timestamps 

make.daily.extract.from.mysql.slow.log.sh filters by db name if provided from the command line 
```{r, engine='bash', count_lines}
root@mysql_db_1:[Thu Nov 12 05:27:17][/tmp]$ /root/bin/make.daily.extract.from.mysql.slow.log.sh /tmp/mysql_db_1-slow.log bsms
Thu Nov 12 05:27:36 EST 2015 : FYI we detected configured slow log here: /tmp/mysql_db_1-slow.log
Thu Nov 12 05:27:36 EST 2015 : proceeding with the /tmp/mysql_db_1-slow.log slow log ...
Thu Nov 12 05:27:36 EST 2015 : checking for Schema: bsms
Thu Nov 12 05:27:38 EST 2015 : finalized extracing the mysql slow log between 2015-11-11.00.00.00 and 2015-11-12.05.27.36
Thu Nov 12 05:27:38 EST 2015 : the extact is here : /tmp/mysql_db_1.mysql_db_1-slow.log.for.db.bsms.between.2015-11-11.00.00.00.and.2015-11-12.05.27.36.gz
root@mysql_db_1:[Thu Nov 12 05:27:38][/tmp]$
```
