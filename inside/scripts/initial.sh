#! /bin/bash

date=[$(date)]

domain_list=/configs/smartnginx/domain_list
  
if [ -d /data/nginx ]; then
    echo $date "Found PID directory for Nginx, skip mkdir"
  else
    echo $date "Config PID directory for Nginx not found, create it......"
    mkdir -p /data/nginx
fi

  echo $date "Reading from" $domain_list

while read i; do
    echo $date "Found domain name" $i
    
  if [ -d /configs/web/$i ]; then
    echo $date "Found config directory for '$i', skip mkdir"
  else
    echo $date "Config directory for '$i' not found, create it......"
    mkdir -p /configs/web/$i
  fi
  
  if [ -d /data/acme.sh/$i/challenges/.well-known/acme-challenge/ ]; then
    echo $date "Found certificate directory for '$i', skip mkdir"
  else
    echo $date "acme-challenge directory for '$i' not found, create it......"
    mkdir -p /data/acme.sh/$i/challenges/.well-known/acme-challenge/ 
  fi

  if [ -d /data/cert/$i/rsa/sct -a -d /data/cert/$i/ecc/sct ]; then
    echo $date "Found certificate directory for '$i', skip mkdir"
  else
    echo $date "Certificates directory for '$i' not found, create it......"
    mkdir -p /data/cert/$i/rsa/sct
    mkdir -p /data/cert/$i/ecc/sct
  fi
    
  if [ -f /configs/web/$i/$i_final.conf ]; then
    echo $date "Found https config file for '$i', skip generate"
    echo $date "Start issue cert for '$i'"
    /scripts/gen_cert.sh $i
  else
    echo $date "https config file for '$i' not found, generate it......"
    /scripts/gen_cert.sh $i gen_initial_conf
  fi

  if [ -d /logs/web/$i ]; then
    echo $date "Log directory for '$i' found, skip mkdir"
  else
    echo $date "Log directory for '$i' not found, create it......"
    mkdir -p /logs/web/$i
  fi


done < $domain_list
