#! /bin/bash

function renew() {

DOMAIN_LIST=/configs/smartnginx/domain_list

while read i; do
    echo "[$(date)]" "Found domain name" $i

    echo "[$(date)]" [$i] Start renew......

    /scripts/gen_cert.sh $i renew

done < $DOMAIN_LIST

    echo "[$(date)]" Reloading Nginx to apply new cert......

/usr/local/nginx/sbin/nginx -s reload

}

renew > /logs/renew/renew-$(date +%Y-%m-%d-%H%M).log 2>&1 
