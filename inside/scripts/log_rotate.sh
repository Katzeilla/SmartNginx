#! /bin/bash

#########################
#
# This script will be execute hourly via cron
#
#########################

# Fix permission
chown root /configs/logrotate/*.conf

# Rotate Nginx log
/usr/sbin/logrotate /configs/logrotate/web.logrotate.conf

