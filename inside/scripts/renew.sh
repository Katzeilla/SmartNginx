#! /bin/bash

function renew() {

date=[$(date)]

domain_list=/configs/smartnginx/domain_list

while read i; do
    echo $date "Found domain name" $i

    echo $date echo [$i] Start renew......

    /scripts/gen_cert.sh $i renew

done < $domain_list

    echo $date Reloading Nginx to apply new cert......

/usr/local/nginx/sbin/nginx -s reload

}

renew > renew-$(date +%Y-%m-%d-%H%M).log 2>&1 
