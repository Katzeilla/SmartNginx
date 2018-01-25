#! /bin/bash

date=[$(date)]

maintained_domain_list=/configs/smartnginx/maintained_domain_list

new_domain_list=/configs/smartnginx/new_domain_list

sorted_domain_list=/configs/smartnginx/sorted_domain_list

domain_list=/configs/smartnginx/domain_list

~/.acme.sh/acme.sh --list | tail -n +2 | cut -f 1 | sort -u > $maintained_domain_list

sort $domain_list > $sorted_domain_list

comm -13 $maintained_domain_list $sorted_domain_list > $new_domain_list

# Get domains not maintained by acme.sh and write to $maintained_domain_list 

echo $date Preprocess domain list......