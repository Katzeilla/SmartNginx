#! /bin/bash

cd ./inside
dir=$(pwd)
cd ..

date="[$(date)]"


stop_nginx()
{
    docker stop smartnginx
    docker rm smartnginx
}

show_usage()
{
        echo "This is a bash script for manage SmartNginx"
        echo "./main [ACTION]"
        echo
        echo "ACTION:"
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
		echo $date 'Debug Mode'

elif [[ $1 == network ]]; then
    if [[ $2 != "" ]]; then
        flag="--network $2"
        echo Connect to $2
    fi

elif [[ $1 == nginx ]];then
	docker exec -it smartnginx /usr/local/nginx/sbin/nginx -s $2	
        exit

elif [[ $1 == test ]]; then
        echo $date Test Mode
        ls $dir/configs/
        ls $dir/data/
        ls $dir/scripts/
        ls $dir/logs/
        ls $dir/configs/verynginx/
        exit

elif [[ $1 == build ]]; then
        echo $date Start build smartnginx:testing
        docker build . --tag smartnginx:testing
        exit

elif [[ $1 == shell ]]; then
        echo $date Attach bash in smartnginx
        docker exec -it smartnginx bash
        exit

elif [[ $1 == --help ]] || [[ $1 == -h ]] || [[ $1 == help ]]; then
        show_usage
        exit

else
	    echo $date 'Normal Mode'
fi

if [ ! -f $dir/logs ]; then

  echo $date mkdir for logs......
  mkdir -p $dir/logs

fi



docker run -it \
  -p 80:80 \
  -p 443:443 \
  --mount type=bind,source=$dir/configs/,target=/configs/ \
  --mount type=bind,source=$dir/data/,target=/data/ \
  --mount type=bind,source=$dir/scripts/,target=/scripts/ \
  --mount type=bind,source=$dir/logs/,target=/logs/ \
  --mount type=bind,source=$dir/configs/verynginx/,target=/opt/verynginx/verynginx/configs/ \
  --mount type=bind,source=$dir/configs/nginx/nginx.conf,target=/usr/local/nginx/conf/nginx.conf \
  --name smartnginx \
  $flag \
  smartnginx:testing

if [[ $? == 125 ]];
    then
    echo $date "Another Nginx already start, stop it......"
    stop_nginx
    ./main.sh $1
  fi
