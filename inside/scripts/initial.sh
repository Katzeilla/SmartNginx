#! /bin/bash

DOMAIN_LIST=/configs/smartnginx/domain_list

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


echo $date Installing cron task......

echo "00 01 01 */2 * root /scripts/renew.sh" >> cron
echo "00 01 * * * root /scripts/log_rotate.sh" >> cron

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

  echo $date "Reading from" $DOMAIN_LIST

while read i; do

./init_site.sh $i

done < $DOMAIN_LIST

initial_verynginx
