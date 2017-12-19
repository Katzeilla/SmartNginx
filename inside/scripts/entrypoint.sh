#! /bin/bash

echo "Starting SmartNginx......"

start_cron ()
{
  echo "Starting cron......"

  /usr/sbin/cron
  
  cron_status=$?

  if [ $cron_status -ne 0 ]; then
    echo "Failed to start cron: exit $cron_status"
  exit $cron_status
fi

}

start_nginx () 
{
  echo "Starting Nginx......"

  /usr/local/nginx/sbin/nginx

  nginx_status=$?

    if [ $nginx_status -ne 0 ]; then
      echo "Failed to start Nginx: exit $nginx_status"
    exit $nginx_status
  else
    exit 0;
  fi
}  

  start_cron
  ps aux
  start_nginx
  ps aux

