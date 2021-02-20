#! /bin/bash

DOMAIN_LIST=/configs/smartnginx/domain_list

echo "[$(date)]" Installing nginx.conf......

ln -s /configs/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf

echo "[$(date)]" Installing cron task......

echo "00 01 01 */2 * /scripts/renew.sh" >> task
echo "00 01 *  *   * /scripts/log_rotate.sh" >> task

crontab task
rm task

if [ -d /data/nginx ]; then
    echo "[$(date)]" "Found PID directory for Nginx, skip mkdir"
  else
    echo "[$(date)]" "PID directory for Nginx not found, create it......"
    mkdir -p /data/nginx
fi

if [ -d /data/pagespeed ]; then
    echo "[$(date)]" "Found directory for PageSpeed, skip mkdir"
  else
    echo "[$(date)]" "Directory for Nginx not found, create it......"
    mkdir -p /data/pagespeed
fi

  echo "[$(date)]" "Reading from" $DOMAIN_LIST

# disable SC2162 in shellcheck as backslash doesn't matter here
# shellcheck disable=SC2162
while read domain; do
  /scripts/init_site.sh "$domain"
done < "$DOMAIN_LIST"
