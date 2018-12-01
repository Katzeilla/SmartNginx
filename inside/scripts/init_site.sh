#! /bin/bash

date=[$(date)]

echo $date "Found domain name" $i
    
  if [ -d /configs/web/$i ]; then
    echo $date "Found config directory for '$i', skip mkdir"
  else
    echo $date "Config directory for '$i' not found, create it......"
    mkdir -p /configs/web/$i
  fi
  
  if [ -d /data/web/$i ]; then
    echo $date "Found data directory for '$i', skip mkdir"
  else
    echo $date "Data directory for '$i' not found, create it......"
    mkdir -p /data/web/$i
    cp /data/template/index.html.template  /data/web/$i/index.html

  fi
  
  if [ -d /logs/web/$i ]; then
    echo $date "Log directory for '$i' found, skip mkdir"
  else
    echo $date "Log directory for '$i' not found, create it......"
    mkdir -p /logs/web/$i
  fi
  
  if [ -d /data/acme.sh/$i/challenges/.well-known/acme-challenge/ ]; then
    echo $date "Found certificate directory for '$i', skip mkdir"
  else
    echo $date "acme-challenge directory for '$i' not found, create it......"
    mkdir -p /data/acme.sh/$i/challenges/.well-known/acme-challenge/ 
  fi

  if [ -d /data/cert/$i/ras/sct -a -d /data/cert/$i/ecc/sct ]; then
    echo $date "Found certificate directory for '$i', skip mkdir"
  else
    echo $date "Certificates directory for '$i' not found, create it......"
    mkdir -p /data/cert/$i/ras/sct
    mkdir -p /data/cert/$i/ecc/sct
  fi
    
  if [ -f /configs/web/$i/$i_final.conf ]; then
    echo $date "Found final config file for '$i', skip generate"
    echo $date "Start issue cert for '$i'"
    /scripts/gen_cert.sh $i
  else
    echo $date "Final config file for '$i' not found, generate it......"
    /scripts/gen_cert.sh $i gen_initial_conf
  fi



