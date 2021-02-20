#! /bin/bash

if [[ -f run_count ]]; then
    # Read run_count from file
    run_count=$(<run_count)
else
    echo 0 > run_count
    run_count=$(<run_count)
fi
    
(( run_count++ ))

# Save new value of run_count to file
echo $run_count > run_count

nginx_signal()
{
  /usr/local/nginx/sbin/nginx -s $1
}

gen_initial_conf()
{
  cp /configs/nginx/web.conf.template.initial /configs/web/$1/$1.conf
  sed -i -e "s/<domain_name>/$1/g" /configs/web/$1/$1.conf
  /usr/local/nginx/sbin/nginx
}

gen_cert()
{
  is_staging()
  {
    if [ -a /configs/smartnginx/staging.flag ]; then
      true;
    else
      false;
    fi
  }
  
  if is_staging; then
    _arg="--staging"
  fi

    /root/.acme.sh/acme.sh \
    "$_arg" \
    --issue \
    --force \
    -d $1 \
    -w /data/acme.sh/$1/challenges/

    /root/.acme.sh/acme.sh \
    --install-cert \
    --nocron \
    -d $1 \
    --key-file /data/cert/$1/ras/key.pem \
    --fullchain-file /data/cert/$1/ras/cert.pem 
    
    if !(is_staging); then
      echo "[$(date)]" [$1] Submit RAS certificate to COMODO sabre ct log server......
      ct-submit sabre.ct.comodo.com < /data/cert/$1/ras/cert.pem > /data/cert/$1/ras/sct/comodo_sabre.sct
      echo "[$(date)]" [$1] Submit RAS certificate to COMODO mammoth ct log server......
      ct-submit mammoth.ct.comodo.com < /data/cert/$1/ras/cert.pem > /data/cert/$1/ras/sct/comodo_mammoth.sct
    fi

  /root/.acme.sh/acme.sh \
    "$_arg" \
    --issue \
    --force \
    -d $1 \
    -w /data/acme.sh/$1/challenges/ \
    --keylength ec-384
  
  /root/.acme.sh/acme.sh \
    --install-cert \
    -d $1 \
    --nocron \
    --ecc \
    --key-file /data/cert/$1/ecc/key.pem \
    --fullchain-file /data/cert/$1/ecc/cert.pem
 
  if !(is_staging); then
    echo "[$(date)]" [$1] Submit ECC certificate to COMODO sabre ct log server......
    ct-submit sabre.ct.comodo.com < /data/cert/$1/ecc/cert.pem > /data/cert/$1/ecc/sct/comodo_sabre.sct
    echo "[$(date)]" [$1] Submit ECC certificate to COMODO mammoth ct log server......
    ct-submit mammoth.ct.comodo.com < /data/cert/$1/ecc/cert.pem > /data/cert/$1/ecc/sct/comodo_sabre.sct
  fi

  rm /configs/web/$1/$1.conf
}

gen_main_conf()
{
  cp /configs/nginx/web.conf.template.main /configs/web/$1/$1_final.conf
  sed -i -e "s/<domain_name>/$1/g" /configs/web/$1/$1_final.conf

}

gen_sub_conf()
{
  cp /configs/nginx/web.conf.template.sub /configs/web/$1/$1_final.conf
  sed -i -e "s/<domain_name>/$1/g" /configs/web/$1/$1_final.conf

}

if [[ $2 == gen_initial_conf ]]; then

    gen_initial_conf $1
    gen_cert $1

        if [[ $run_count == 1 ]]; then
            gen_main_conf $1
        else
            gen_sub_conf $1
        fi
    
    nginx_signal stop

elif [[ $2 == renew ]]; then
    gen_cert $1

else	
    gen_cert $1
    stop_nginx

fi
