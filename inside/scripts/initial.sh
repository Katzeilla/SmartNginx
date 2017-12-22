#! /bin/bash

date=[$(date)]

domain_list=/configs/smartnginx/domain_list

echo $date "Reading from" $domain_list

while read i; do
    echo $date "Found domain name" $i
    
  if [ -d /configs/web/$i ]; then
    echo $date "Found config directory for '$i', skip mkdir"
  else
    echo $date "Config directory for '$i' not found, create it......"
    mkdir /configs/web/$i
  fi

  if [ -f /configs/web/$i/$i_final.conf ]; then
    echo $date "Found https config file for '$i', skip generate"
    echo $date "Start issue cert for '$1'"
    ./gen_cert.sh $i
  else
    echo $date "https config file for '$i' not found, generate it......"
    ./gen_cert.sh $i gen_initial_conf
  fi

  if [ -d /logs/web/$i ]; then
    echo $date "Log directory for '$i' found, skip mkdir"
  else
    echo $date "Log directory for '$i' not found, create it......"
    mkdir -p /logs/web/$i
  fi


done < $domain_list
