#! /bin/bash

date=[$(date)]

initial_verynginx()
{

grep '"password":"verynginx",' /configs/verynginx/config.json -q

if [[ $? == 0 ]]; then
  echo $date  "Found weak password in VeryNginx config, generate a random one for you, you may change it later in dashboard"
  echo "####################################################################################"
  echo "Login to your VeryNginx dashboard later at https://your_domain/verynginx/index.html"
  randompw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  sed -i -e "s/\"password\":\"verynginx\",/\"password\":\"$randompw\",/g" /configs/verynginx/config.json
  echo "Username: verynginx"
  echo "Password:" $randompw
  echo "####################################################################################"
fi
}



domain_list=/configs/smartnginx/domain_list


echo $date Installing cron task......

echo "00 00 01 */3 * /scripts/renew.sh" > cron
crontab cron
rm cron

if [ -d /data/nginx ]; then
    echo $date "Found PID directory for Nginx, skip mkdir"
  else
    echo $date "PID directory for Nginx not found, create it......"
    mkdir -p /data/nginx
fi

if [ -d /data/pagespeed ]; then
    echo $date "Found directory for PageSpeed, skip mkdir"
  else
    echo $date "Directory for Nginx not found, create it......"
    mkdir -p /data/pagespeed
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



done < $domain_list
