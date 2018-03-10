#! /bin/bash

date=[$(date)]

domain_list=/configs/smartnginx/domain_list

while read i; do
    echo $date "Found domain name" $i

    echo $date echo [$i] Start renew......

    /scripts/gen_cert.sh $i renew

done < $domain_list
