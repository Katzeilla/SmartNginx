#! /bin/bash

VERSION='v1.0.0'

cd ./inside
dir=$(pwd)
cd ..

stop_nginx()
{
    docker stop smartnginx
    docker rm smartnginx
}

_pull() {
    docker pull miaowo/smartnginx:$VERSION
}

show_usage()
{
        echo "This is a bash script for manage SmartNginx"
        echo "./main [ACTION]"
        echo
        echo "ACTION:"
        echo "staging                                  toggle staging mode"
        echo "pull                   pull the latest image from Docker Hub"
        echo "test                                ls all mount dir of host"
	echo "network <network_name>		      Connect to a network"
        echo "nginx [stop|quit|reload|reopen]        Send signal to  Nginx"
        echo "debug                                       Start in to bash"
	echo "shell                  Attach shell of the running container"
        echo "--help, -h ,help                           Show this message"
        echo
        echo "If no [ACTION], start normally"
}

  if [[ $1 == debug ]]; then
        flag='--entrypoint /bin/bash'
		echo "[$(date)]" 'Debug Mode'

elif [[ $1 == network ]]; then
    if [[ $2 != "" ]]; then
        flag="--network $2"
        echo Connect to $2
    fi

elif [[ $1 == staging ]];then
	if [ -a "$dir/inside/configs/smartnginx/staging.flag" ]; then
		touch "$dir/configs/smartnginx/staging.flag"
        	exit
	else
		rm "$dir/configs/smartnginx/staging.flag"
		exit
	fi
elif [[ $1 == pull ]];then
	_pull
        exit

elif [[ $1 == nginx ]];then
	docker exec -it smartnginx /usr/local/nginx/sbin/nginx -s $2	
        exit

elif [[ $1 == test ]]; then
        echo "[$(date)]" Test Mode
        ls $dir/configs/
        ls $dir/data/
        ls $dir/scripts/
        ls $dir/logs/
        exit

elif [[ $1 == build || $1 == make ]]; then
        echo "[$(date)]" "Building smartnginx:$VERSION..."
        docker build . --tag smartnginx:$VERSION
        exit

elif [[ $1 == shell ]]; then
        echo "[$(date)]" Attach bash in smartnginx
        docker exec -it smartnginx bash
        exit

elif [[ $1 == --help ]] || [[ $1 == -h ]] || [[ $1 == help ]]; then
        show_usage
        exit

else
	    echo "[$(date)]" 'Normal Mode'
fi

if [ ! -f $dir/logs ]; then

  echo "[$(date)]" mkdir for logs......
  mkdir -p $dir/logs

fi



docker run -it \
  -p 80:80 \
  -p 443:443 \
  --mount type=bind,source=$dir/configs/,target=/configs/ \
  --mount type=bind,source=$dir/data/,target=/data/ \
  --mount type=bind,source=$dir/scripts/,target=/scripts/ \
  --mount type=bind,source=$dir/logs/,target=/logs/ \
  --mount type=bind,source=$dir/configs/nginx/nginx.conf,target=/usr/local/nginx/conf/nginx.conf \
  --name smartnginx \
  $flag \
  miaowo/smartnginx:$VERSION

if [[ $? == 125 ]];
    then
    echo "[$(date)]" "Another Nginx already start, stop it......"
    stop_nginx
    ./main.sh $1
  fi
