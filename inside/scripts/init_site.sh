#! /bin/bash

domain="$1"

echo "[$(date)]" "Found domain name" "$domain"
    
  if [ -d /configs/web/"$domain" ]; then
    echo "[$(date)]" "Found config directory for $domain, skip mkdir"
  else
    echo "[$(date)]" "Config directory for $domain not found, create it......"
    mkdir -p /configs/web/"$domain"
  fi
  
  if [ -d /data/web/"$domain" ]; then
    echo "[$(date)]" "Found data directory for $domain, skip mkdir"
  else
    echo "[$(date)]" "Data directory for $domain not found, create it......"
    mkdir -p /data/web/"$domain"
    cp /data/template/index.html.template  /data/web/"$domain"/index.html

  fi
  
  if [ -d /logs/web/"$domain" ]; then
    echo "[$(date)]" "Log directory for $domain found, skip mkdir"
  else
    echo "[$(date)]" "Log directory for $domain not found, create it......"
    mkdir -p /logs/web/"$domain"
  fi
  
  if [ -d /data/acme.sh/"$domain"/challenges/.well-known/acme-challenge/ ]; then
    echo "[$(date)]" "Found certificate directory for $domain, skip mkdir"
  else
    echo "[$(date)]" "acme-challenge directory for $domain not found, create it......"
    mkdir -p /data/acme.sh/"$domain"/challenges/.well-known/acme-challenge/ 
  fi

  if [ -d /data/cert/"$domain"/ras/sct ] && [ -d /data/cert/"$domain"/ecc/sct ]; then
    echo "[$(date)]" "Found certificate directory for $domain, skip mkdir"
  else
    echo "[$(date)]" "Certificates directory for $domain not found, create it......"
    mkdir -p /data/cert/"$domain"/ras/sct
    mkdir -p /data/cert/"$domain"/ecc/sct
  fi
    
  if [ -f /configs/web/"$domain"/"$domain"_final.conf ]; then
    echo "[$(date)]" "Found final config file for $domain, skip generate"
    echo "[$(date)]" "Start issue cert for $domain"
    /scripts/gen_cert.sh "$domain"
  else
    echo "[$(date)]" "Final config file for $domain not found, generate it......"
    /scripts/gen_cert.sh "$domain" gen_initial_conf
  fi



