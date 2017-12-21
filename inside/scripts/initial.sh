#! /bin/bash

date=[$(date)]

domain_list=/configs/smartnginx/domain_list

echo $date "Reading from" $domain_list

while read i; do
    echo $date "Found domain name" $i
    
  if [ -d /configs/$i ]; then
    echo $date "Found config directory for" $i ", skip mkdir"
  else
    echo $date "Config directory for" $i "not found, create it......"
    mkdir /configs/web/$i
  fi

  if [ -f /configs/$i/*.conf ]; then
    echo $date "Found .conf file for" $i ", skip mkdir"
  else
    echo $date ".conf file for" $i "not found, generate it......"
  fi

  if [ -d /logs/web/$i ]; then
    echo $date "Log directory for" $i "found, skip mkdir"
  else
    echo $date "Log directory for" $i "not found, create it......"
    mkdir -p /logs/web/$i
  fi


done < $domain_list
