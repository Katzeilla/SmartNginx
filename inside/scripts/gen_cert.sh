#! /bin/bash

if [[ -f run_count ]]; then
    # Read run_count from file
    run_count="$(<run_count)"
else
    echo 0 > run_count
    run_count="$(<run_count)"
fi
    
(( run_count++ ))

# Save new value of run_count to file
echo "$run_count" > run_count

nginx_signal()
{
  /usr/local/nginx/sbin/nginx -s "$1"
}

gen_initial_conf()
{
  domain="$1"
  cp /configs/nginx/web.conf.template.initial "/configs/web/$domain/$domain.conf"
  sed -i -e "s/<domain_name>/$domain/g" "/configs/web/$domain/$domain.conf"
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

    domain="$1"

    /root/.acme.sh/acme.sh \
    "$_arg" \
    --issue \
    --force \
    -d "$domain" \
    -w /data/acme.sh/"$domain"/challenges/

    /root/.acme.sh/acme.sh \
    --install-cert \
    --nocron \
    -d "$domain" \
    --key-file /data/cert/"$domain"/ras/key.pem \
    --fullchain-file /data/cert/"$domain"/ras/cert.pem 
    
    if ! (is_staging); then
      echo "[$(date)]" ["$domain"] Submit RAS certificate to COMODO sabre ct log server......
      ct-submit sabre.ct.comodo.com \
	      < /data/cert/"$domain"/ras/cert.pem \
	      > /data/cert/"$domain"/ras/sct/comodo_sabre.sct
      echo "[$(date)]" ["$domain"] Submit RAS certificate to COMODO mammoth ct log server......
      ct-submit mammoth.ct.comodo.com \
	      < /data/cert/"$domain"/ras/cert.pem \
	      > /data/cert/"$domain"/ras/sct/comodo_mammoth.sct
    fi

  /root/.acme.sh/acme.sh \
    "$_arg" \
    --issue \
    --force \
    -d "$domain" \
    -w /data/acme.sh/"$domain"/challenges/ \
    --keylength ec-384
  
  /root/.acme.sh/acme.sh \
    --install-cert \
    -d "$domain" \
    --nocron \
    --ecc \
    --key-file /data/cert/"$domain"/ecc/key.pem \
    --fullchain-file /data/cert/"$domain"/ecc/cert.pem
 
  if ! (is_staging); then
    echo "[$(date)]" ["$domain"] Submit ECC certificate to COMODO sabre ct log server......
    ct-submit sabre.ct.comodo.com \
	    < /data/cert/"$domain"/ecc/cert.pem \
	    > /data/cert/"$domain"/ecc/sct/comodo_sabre.sct
    echo "[$(date)]" [$1] Submit ECC certificate to COMODO mammoth ct log server......
    ct-submit mammoth.ct.comodo.com \
	    < /data/cert/"$domain"/ecc/cert.pem \
	    > /data/cert/"$domain"/ecc/sct/comodo_sabre.sct
  fi

  rm "/configs/web/$domain/$domain.conf"
}

gen_main_conf()
{
  domain="$1"
  cp /configs/nginx/web.conf.template.main /configs/web/"$domain"/"$domain"_final.conf
  sed -i -e "s/<domain_name>/$domain/g" /configs/web/"$domain"/"$domain"_final.conf

}

gen_sub_conf()
{
  domain="$1"
  cp /configs/nginx/web.conf.template.sub /configs/web/"$domain"/"$domain"_final.conf
  sed -i -e "s/<domain_name>/$domain/g" /configs/web/"$domain"/"$domain"_final.conf

}

if [[ "$2" == gen_initial_conf ]]; then

    domain="$1"
    gen_initial_conf "$domain"
    gen_cert "$domain"

    if [[ "$run_count" == 1 ]]; then
      gen_main_conf "$domain"
    else
      gen_sub_conf "$domain"
    fi
    
    nginx_signal stop

elif [[ "$2" == renew ]]; then
    gen_cert "$domain"

else	
    gen_cert "$domain"
    stop_nginx

fi
