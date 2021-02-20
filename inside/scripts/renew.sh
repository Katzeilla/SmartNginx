#! /bin/bash

function renew() {

DOMAIN_LIST=/configs/smartnginx/domain_list

while read domain; do
    echo "[$(date)]" "Found domain name" "$domain"

    echo "[$(date)]" [$domain] Start renew......

    /scripts/gen_cert.sh "$domain" renew

done < $DOMAIN_LIST

    echo "[$(date)]" Reloading Nginx to apply new cert......

/usr/local/nginx/sbin/nginx -s reload

}

renew > /logs/renew/renew-$(date +%Y-%m-%d-%H%M).log 2>&1 
