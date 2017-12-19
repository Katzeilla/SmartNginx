#! /bin/bash

echo "Starting SmartNginx......"

start_cron ()
{
  echo "Starting cron......"

  /usr/sbin/cron

  status=$?

  if [[ $status -ne 0 ]]; then
      echo "Failed to start cron: exit $status"
      exit $status
  fi

}

start_nginx ()
{
  echo "Starting Nginx......"
  
  /usr/local/nginx/sbin/nginx
  
  status=$?

  if [[ $status -ne 0 ]]; then
     echo "Failed to start Nginx: exit $status"
     exit $status
  fi
}

start_cron
start_nginx

nginx_restart_count=0
cron_restart_count=0

# Main loop for every 1 min.

auto_reload()
{
    while /bin/true; do
        /usr/local/nginx/sbin/nginx -s reload
        sleep 3
    done 
}

auto_reload &

while /bin/true; do

    ps aux | grep nginx | grep -q -v grep
    nginx_status=$?
    ps aux | grep cron | grep -q -v grep
    cron_status=$?

    if [[ $cron_status -ne 0 ]]; then
        let cron_restart_count++
        echo "cron exited with code $cron_status"
        
        # Avoid "4/3 attempt"
        if [[ $cron_restart_count < "4" ]]; then
        echo "Attempt to restart, this is the $cron_restart_count/3 attempt"
        fi
   fi

    if [[ $nginx_status -ne 0 ]]; then
        let nginx_restart_count++ 
        echo "Nginx exited with code $nginx_status"
        
        # Avoid "4/3 attempt"
        if [[ $nginx_restart_count < "4" ]]; then
        echo "Attempt to restart, this is the $nginx_restart_count/3 attempt"
        fi
    fi


   # echo $nginx_status
   # echo $cron_status
   # echo $nginx_restart_count
   # echo $cron_status
   # For debug


    if [[ $nginx_restart_count -gt 3 ]] || [[ $cron_restart_count -gt 3 ]]; then
        echo "To many restart, exit now......"
        exit 1;
    fi

    sleep 60

  done
