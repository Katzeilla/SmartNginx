#! /bin/bash

while read i; do
    echo "Found domain name" $i
done < ../configs/smartnginx/domain_list
