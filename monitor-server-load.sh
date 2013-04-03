#! /bin/sh
#
# Script to send email notification if a server exceeds a specified load average.
# Selected load average limit.  If above this number a notification message will be emailed.

NOTIFY="5"
TRUE="1"

# Email address to receive alerts.
EMAIL="your@email.com"

# Create a temp file
TEMPFILE="$(mktemp)"

# The text which will be awk'ed a few times looking for the same text, so we specify it here once.
FTEXT='load average:'

# Get the load average for the last 1 minutes.
LOAD1MIN="$(uptime | awk -F "$FTEXT" '{ print $2 }' | cut -d, -f1 | sed 's/ //g')"

# Get the load average for the last 10 minutes.
LOAD5MIN="$(uptime | awk -F "$FTEXT" '{ print $2 }' | cut -d, -f2 | sed 's/ //g')"

# Get the load average for the last 15 minutes.
LOAD15MIN="$(uptime | awk -F "$FTEXT" '{ print $2 }' | cut -d, -f3 | sed 's/ //g')"

# awk the memory stats
MEMU="$(free -tom | awk '/Total:/ {print "Total memory: "$2" MB\nUsed memory: "$3" MB\nFree memory: "$4" MB"}')"

# Email subject
SUBJECT="Alert $(hostname) high load average: $LOAD5MIN"

# Mail message body
echo "Server 5 min load average $LOAD5MIN is above notification threshold $NOTIFY" >> $TEMPFILE
echo " " >> $TEMPFILE
echo "Hostname: $(hostname)" >> $TEMPFILE
echo "Local Date & Time : $(date)" >> $TEMPFILE
echo " " >> $TEMPFILE
echo "Server load for the last five minutes: $LOAD5MIN" >> $TEMPFILE
echo "Server load for the last fifteen minutes: $LOAD15MIN" >> $TEMPFILE
echo " " >> $TEMPFILE
echo "------------------------" >> $TEMPFILE
echo "Memory stats:" >> $TEMPFILE
echo "------------------------" >> $TEMPFILE
echo "$MEMU" >> $TEMPFILE
echo " " >> $TEMPFILE

# Look if the limit has been exceeded, compared with the last 15 min load average.
# Check if the load average is larger than the specified limit.
# bc will return true or false.
RESULT=$(echo "$LOAD5MIN > $NOTIFY" | bc)

# If the result is true, send the message
if [ "$RESULT" -eq "$TRUE" ]; then
        # echo true
        mail -s "$SUBJECT" $EMAIL < $TEMPFILE
fi