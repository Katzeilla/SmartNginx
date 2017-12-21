#! /bin/bash

date=[$(date)]

domain_list=/configs/smartnginx/domain_list

# Usage:
# gen_conf <location of config file> <domain name>


gen_conf()
{
  cp /configs/nginx/web.conf.template $1
  sed -i -e "s/<domain_name>/$2/g" $1
}

echo $date "Reading from" $domain_list

while read i; do
    echo $date "Found domain name" $i
    
  if [ -d /configs/web/$i ]; then
    echo $date "Found config directory for '$i', skip mkdir"
  else
    echo $date "Config directory for '$i' not found, create it......"
    mkdir /configs/web/$i
  fi

  if [ -f /configs/web/$i/*.conf ]; then
    echo $date "Found .conf file for '$i', skip mkdir"
  else
    echo $date ".conf file for '$i' not found, generate it......"
    gen_conf /configs/web/$i/$i.conf $i
  fi

  if [ -d /logs/web/$i ]; then
    echo $date "Log directory for '$i' found, skip mkdir"
  else
    echo $date "Log directory for '$i' not found, create it......"
    mkdir -p /logs/web/$i
  fi


done < $domain_list
