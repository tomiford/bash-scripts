#!/bin/sh
# Script that checks whether apache is still up, and if not:
# - e-mail the last bit of log files
# - restarts it

PATH=/bin:/usr/bin
THEDIR=/tmp/apache-watchdog
EMAIL=your@email.com
mkdir -p $THEDIR

if ( wget --timeout=20 -q -P $THEDIR http://www.your-site.com/index.php ); then
    # we are up
    touch ~/.apache-was-up
    rm $THEDIR/index.php
else
    # down! but if it was down already, don't keep spamming
    if [ -f ~/.apache-was-up ]; then
        # write a nice e-mail
        echo -n "Apache crashed at " > $THEDIR/mail
        date >> $THEDIR/mail
        echo >> $THEDIR/mail
        echo "------------------------" >> $THEDIR/mail
        echo "Syslog:" >> $THEDIR/mail
        echo "------------------------" >> $THEDIR/mail
        tail -n 30 /var/log/syslog >> $THEDIR/mail
        echo >> $THEDIR/mail
        echo "------------------------" >> $THEDIR/mail
        echo "Error log:" >> $THEDIR/mail
        echo "------------------------" >> $THEDIR/mail
        tail -n 30 /var/log/apache2/error.log >> $THEDIR/mail
        echo >> $THEDIR/mail
        # restart apache
        echo "Restarting apache..." >> $THEDIR/mail
        service apache2 stop >> $THEDIR/mail 2>&1
        killall -9 apache2 >> $THEDIR/mail 2>&1
        service apache2 start >> $THEDIR/mail 2>&1
        echo >> $THEDIR/mail
        echo "Good luck troubleshooting!" >> $THEDIR/mail
        mail -s "Apache-watchdog: $(hostname) apache crashed" $EMAIL < $THEDIR/mail
        rm ~/.apache-was-up
        rm $THEDIR/mail
    fi
fi

rmdir $THEDIR
