#!/bin/sh

mkdir /var/log/server-status
curl -o /var/log/server-status/getstats.sh https://raw.githubusercontent.com/noiseofsilence/serverstatus/main/getstats.sh

echo "* * * * * root /usr/bin/flock -n /var/run/cloudlinux_getstats.cronlock /bin/sh /var/log/server-status/getstats.sh >/dev/null 2>&1 " > /etc/cron.d/getstats
