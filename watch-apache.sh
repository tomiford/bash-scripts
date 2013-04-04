#! /bin/sh
# Command to watch apache memory use

watch -n 1 "echo -n 'Apache Processes: ' && ps -C apache2 --no-headers | wc -l && free -m"