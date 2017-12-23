#! /bin/bash

date=[$(date)]



reload_nginx()
{
  /usr/local/nginx/sbin/nginx -s reload
}

gen_initial_conf()
{
  cp /configs/nginx/web.conf.template.initial /configs/web/$1/$1.conf
  sed -i -e "s/<domain_name>/$1/g" /configs/web/$1/$1.conf
  /usr/local/nginx/sbin/nginx
}

gen_cert()
{

    /root/.acme.sh/acme.sh \
    --issue \
    -d $1 \
    -w /data/acme.sh/$1/challenges/

    /root/.acme.sh/acme.sh \
    --install-cert \
    -d $1 \
    --key-file /data/cert/$1/ras/key.pem \
    --fullchain-file /data/cert/$1/ras/cert.pem 
    
    
    echo $date [$1] Submit RAS certificate to Google icarus ct log server......
    ct-submit ct.googleapis.com/icarus < /data/cert/$1/ras/cert.pem > /data/cert/$1/ras/sct/icarus.sct
    echo $date [$1] Submit RAS certificate to Google pilot ct log server......
    ct-submit ct.googleapis.com/pilot < /data/cert/$1/ras/cert.pem > /data/cert/$1/ras/sct/digicert.sct
    echo $date [$1] Submit RAS certificate to COMODO sabre ct log server......
    ct-submit sabre.ct.comodo.com < /data/cert/$1/ras/cert.pem > /data/cert/$1/ras/sct/sabre.sct
  
  /root/.acme.sh/acme.sh \
    --issue \
    -d $1 \
    -w /data/acme.sh/$1/challenges/ \
    --keylength ec-384
  
  /root/.acme.sh/acme.sh \
    --install-cert \
    -d $1 \
    --ecc \
    --key-file /data/cert/$1/ecc/key.pem \
    --fullchain-file /data/cert/$1/ecc/cert.pem
 
    echo $date [$1] Submit ECC certificate to Google icarus ct log server......
    ct-submit ct.googleapis.com/icarus < /data/cert/$1/ecc/cert.pem > /data/cert/$1/ecc/sct/icarus.sct
    echo $date [$1] Submit ECC certificate to Google pilot ct log server......
    ct-submit ct.googleapis.com/pilot < /data/cert/$1/ecc/cert.pem > /data/cert/$1/ecc/sct/digicert.sct
    echo $date [$1] Submit ECC certificate to COMODO sabre ct log server......
    ct-submit sabre.ct.comodo.com < /data/cert/$1/ecc/cert.pem > /data/cert/$1/ecc/sct/sabre.sct

  rm /configs/web/$1/$1.conf
}

gen_conf()
{
  cp /configs/nginx/web.conf.template /configs/web/$1/$1_final.conf
  sed -i -e "s/<domain_name>/$1/g" /configs/web/$1/$1_final.conf
}

if [[ $2 == gen_initial_conf ]]; then
  gen_initial_conf $1
  gen_cert $1
  gen_conf $1
  reload_nginx
else
  gen_cert $1
  reload_nginx
fi

