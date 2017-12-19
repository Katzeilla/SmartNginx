#! /bin/bash

echo "Starting SmartNginx......"

start_cron ()
{
  echo "Starting cron......"

  /usr/sbin/cron

  if [ $? -ne 0 ]; then
    echo "Failed to start cron: exit $?"
  exit $?
fi

}

start_nginx () 
{
  echo "Starting Nginx......"

  /usr/local/nginx/sbin/nginx

    if [ $? -ne 0 ]; then
      echo "Failed to start cron: exit $?"
    exit $?
  fi
  }

  start_cron
  ps aux
  start_nginx
  pa aux
