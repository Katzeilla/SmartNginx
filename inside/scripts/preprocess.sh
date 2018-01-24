#! /bin/bash

date=[$(date)]

maintained_domain_list=/config/smartnginx/maintained_domain_list

new_domain_list=/config/smartnginx/new_domain_list

sorted_domain_list=/config/smartnginx/sorted_domain_list

domain_list=/config/smartnginx/domain_list

acme.sh --list | tail -n +2 | cut -f 1 | sort -u > $maintained_domain_list

sort $domain_list > $sorted_domain_list

comm -13 $maintained_domain_list $sorted_domain_list > $new_domain_list

# Get domains maintained by acme.sh and write to $maintained_domain_list 

cat $new_domain_list

echo $date
