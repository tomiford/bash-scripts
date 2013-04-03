bash-scripts
============

Useful bash scripts for monitoring a web application

monitor-apache.sh
-----------------
Script that checks whether apache is still up, and if not:
 - e-mail the last bit of log files
 - restarts it

monitor-mysql-slave.sh
-----------------
Script that checks if mysql slave is still in sync with its master, and if not:
 - e-mails alert

monitor-server-load.sh
-----------------
Script that monitors server load average is below the limit set in the script, and if not:
 - e-mail an alert with summary of load average and memory use