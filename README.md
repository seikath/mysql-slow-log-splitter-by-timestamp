# mysql-slow-log-splitter-by-timestamp
Extracts the part of the MariaDB, Percona or MySQL slow log between two timestamps


For the future 2.x release only:
============================
As we will need access to the MariaDB / Percoan / MySQL instance we will need connection information loaded from the *conf file:
Make sure you have the make.weekly.index.usage.report.conf file in the same directory
Format of the conf file is the usual bash sytax:

cat make.weekly.index.usage.report.conf
_user=admin
_password=babami
_host=localhost
============================