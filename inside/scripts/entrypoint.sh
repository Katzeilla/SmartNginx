#! /bin/bash

echo "[$(date)]" "Starting SmartNginx......"

start_cron ()
{
  echo "[$(date)]" "Starting cron......"

  /usr/sbin/cron

  status=$?

  if [[ $status -ne 0 ]]; then
      echo "[$(date)]" "Failed to start cron: exit $status"
      exit $status
  fi

}

start_nginx ()
{
  echo "[$(date)]" "Starting Nginx......"
  
  /usr/local/nginx/sbin/nginx
  
  status=$?

  if [[ $status -ne 0 ]]; then
     echo "[$(date)]" "Failed to start Nginx: exit $status"
     exit $status
  fi
}
echo "[$(date)]" "Run initial script......"

/scripts/initial.sh

start_cron
start_nginx


nginx_restart_count=0
cron_restart_count=0

# Main loop for every 1 min.

reload_nginx()
{
    while /bin/true; do
        /usr/local/nginx/sbin/nginx -s reload
        sleep 3
    done 
}

# auto_reload &

health_check ()
{

while /bin/true; do

    pgrep nginx > /dev/null
    nginx_status=$?
    pgrep cron > /dev/null
    cron_status=$?

    if [[ $cron_status -ne 0 ]]; then
        echo "[$(date)]" "cron exited with code $cron_status"
        (( cron_restart_count++ ))
        if [ $cron_restart_count -le 3 ]; then
        echo "[$(date)]" "Attempt to restart, this is the $cron_restart_count/3 attempt"
        start_cron
        fi
   fi

    if [[ $nginx_status -ne 0 ]]; then
	echo "[$(date)]" "Nginx exited with code $nginx_status"
        (( nginx_restart_count++ ))
        if [ $nginx_restart_count -le 3 ]; then
        echo "[$(date)]" "Attempt to restart, this is the $nginx_restart_count/3 attempt"
        start_nginx
        fi
    fi

    if [[ $nginx_restart_count -gt 3 ]] || [[ $cron_restart_count -gt 3 ]]; then
        echo "[$(date)]" "Too many restart, exit now......"
        exit 1;
    fi

    sleep 5

  done

  }

  health_check
