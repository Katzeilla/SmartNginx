#! /bin/bash

VERSION='latest'
flag=''

cd ./inside || (echo 'required directories not found' && exit)
dir="$(pwd)"
cd ..

stop_nginx()
{
  docker stop smartnginx
  docker rm smartnginx
}

_pull() {
  docker pull miaowo/smartnginx:"$VERSION"
}

_start() {
  # shellcheck disable=SC2086
  # $flag can't be double quoted
  docker run -it \
    -p 80:80 \
    -p 443:443 \
    --mount type=bind,source="$dir/configs/",target=/configs/ \
    --mount type=bind,source="$dir/data/",target=/data/ \
    --mount type=bind,source="$dir/scripts/",target=/scripts/ \
    --mount type=bind,source="$dir/logs/",target=/logs/ \
    --name smartnginx \
    $flag \
    miaowo/smartnginx:"$VERSION"
}

show_usage()
{
  echo "This is a bash script for manage SmartNginx"
  echo "./main [ACTION]"
  echo
  echo "ACTION:"
  echo "start                                  Start container"
  echo "staging                                toggle staging mode"
  echo "pull                                   pull the latest image from Docker Hub"
  echo "nginx [stop|quit|reload|reopen]        Send signal to  Nginx"
  echo "debug                                  Start in to bash"
  echo "shell                                  Attach shell of the running container"
  echo "--help, -h ,help                       Show this message"
  echo
  echo "If no [ACTION], start normally"
}

if [[ "$1" == debug ]]; then
  flag='--entrypoint /bin/bash'
  echo "[$(date)]" 'Debug Mode'
  _start

elif [[ "$1" == staging ]];then
  if [ -a "$dir/inside/configs/smartnginx/staging.flag" ]; then
    rm "$dir/configs/smartnginx/staging.flag"
    exit
  else
    touch "$dir/configs/smartnginx/staging.flag"
    exit
  fi

elif [[ "$1" == pull ]];then
  _pull
  docker tag miaowo/smartnginx smartnginx
  exit

elif [[ "$1" == nginx ]];then
  docker exec -it smartnginx /usr/local/nginx/sbin/nginx -s "$2"	
  exit

elif [[ "$1" == build || "$1" == make ]]; then
  echo "[$(date)]" "Building smartnginx:$VERSION..."
  docker build . --tag smartnginx:"$VERSION"
  exit

elif [[ "$1" == shell ]]; then
  echo "[$(date)]" Attach bash in smartnginx
  docker exec -it smartnginx bash
  exit

elif [[ "$1" == start ]]; then
  echo "[$(date)]" 'Normal Mode'
  _start

else
  show_usage
fi
