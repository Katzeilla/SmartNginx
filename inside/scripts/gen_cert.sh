#! /bin/bash

date=[$(date)]

alias acme.sh=/root/.acme.sh/acme.sh

if [[ $2 == gen_initial_conf ]]; then
  gen_initial_conf
  gen_cert
  gen_conf
  install_cert
else
  gen_cert
  install_cert
fi

gen_initial_conf()
{
  cp /configs/nginx/web.conf.template.initial /configs/web/$1/$1.conf
  sed -i -e "s/<domain_name>/$1/g" /configs/web/$1.conf
}

gen_cert()
{
  acme.sh 
  rm /configs/web/$1/$1.conf
}

gen_conf()
{
  cp ../configs/nginx/web.conf.template ../configs/web/$1/$1_https.conf
  sed -i -e "s/<domain_name>/$1/g" ../configs/web/$1/$1_https.conf
}

install_cert()
{
  acme.sh 
}
