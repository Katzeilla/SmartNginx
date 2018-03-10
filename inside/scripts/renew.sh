#! /bin/bash

date=[$(date)]

domain_list=/configs/smartnginx/domain_list

while read i; do
    echo $date "Found domain name" $i
done < $domain_list
