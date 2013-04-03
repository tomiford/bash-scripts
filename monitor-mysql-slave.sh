#!/bin/sh
# Script that checks if mysql slave is still in sync with its master

# Create a temp file
TEMPFILE="$(mktemp)"

# Email address to receive alerts.
EMAIL="your@email.com"

# Get "seconds behind master" for slave
SECONDS_BEHIND_MASTER=`/usr/bin/mysql -uYOUR_USER -pYOUR_PASSWORD -e "SHOW SLAVE STATUS\G" | grep "Seconds_Behind_Master" | awk -F ": " {'print $2'}`

if [ "$SECONDS_BEHIND_MASTER" -le "120" ]; then
    # we are in sync
    touch ~/.mysql-slave-in-sync
else
    # slave behind master, only email once
    if [ -f ~/.mysql-slave-in-sync ]; then
        # write a nice e-mail
        echo -n "MySQL slave is " > $TEMPFILE
        $SECONDS_BEHIND_MASTER > $TEMPFILE
        echo " it's master at " > $TEMPFILE
        date >> $TEMPFILE
        echo '.' >> $TEMPFILE
        echo >> $TEMPFILE
        mail -s "Mysql-watchdog: $(hostname) slave behind master" $EMAIL < $TEMPFILE
        rm ~/.mysql-slave-in-sync
    fi
fi